import wikipedia
import json
import markdown
import logging
import os

from flask import Flask, jsonify, request, render_template, Markup

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm.exc import NoResultFound


from sqlalchemy_declarative import (Base,
                                    User,
                                    Artikel,
                                    Schlagwort,
                                    PersonalizedArtikel,
                                    Rating)
from util import *
from error_handler import error_handler
from Wikipedia_Entry import Wikipedia_Entry
from Response import Response

app = Flask(__name__)


@app.route('/', methods=['GET'])
def readme():
    with open("README.md", "r") as myfile:
        content = myfile.read()
        content = Markup(markdown.markdown(content))
    return render_template('index.html', **locals())


@app.route('/get/articles/<latitude>/<longitude>/', methods=['GET'])
@app.route('/get/articles/<latitude>/<longitude>', methods=['GET'])
def getLocations(latitude, longitude, **kwargs):
    '''
    Returns an ArrayList with locations Objects.

    It expects a latitude and a longitude as parameters.

    When the function is called a geosearch api call to wikipedia
    is sent. The response of that Api call is used to determine
    what attractions are near the user.

    Before we send anymore requests to other Apis we check if we already
    have a database entry for the specific pageWikiID
    (For now only from the english wikipedia)

    If we already have information about the place we send those
    out to the user, if we dont we start to collect the data from other apis.
    '''
    try:
        if request.args.get('user', None):
            userID = int(request.args.get('user'))
        else:
            userID = None
        radius = int(request.args.get('radius', 1000))
        latitude = float(latitude)
        longitude = float(longitude)
    except ValueError:
        return Response("Nothing found, but we are never gona give you up, let you down ....", 404).response()
    session = DBSession()
    articles = []
    wikiCategorieBlacklist = ['adm2nd', 'adm1st', 'adm3nd', 'river', 'forest']
    for article in geosearch(latitude, longitude, 'landmark', radius):
        if article.get('type') in wikiCategorieBlacklist:
            continue
        if len(articles) > 15:
            break
        title = article.get('title')
        latitude = article.get('lat')
        longitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')
        entry = Wikipedia_Entry.fromWikiID(page_ID, distance, session)
        if not entry:
             # Google Api
            googleResults = getPlacesAtLocation(latitude,
                                                longitude,
                                                70)
            types = googleResults.get('types')
            opening_hours = googleResults['opening_times']
            address = googleResults.get('address')
            # Wiki Api
            image = getImage([str(page_ID)])
            page = wikipedia.page(title, auto_suggest=True, redirect=False)

            # Alchemy Api
            keywords = getSchlagworter(page.title, page.url)
            new_articel = Artikel(address=address,
                                  latitude=latitude,
                                  longitude=longitude,
                                  pageWikiId=page_ID,
                                  gattung=types,
                                  offnungszeiten=json.dumps(opening_hours),
                                  title=title,
                                  url=page.url,
                                  picUrl=image)
            for key in keywords:
                k = Schlagwort(text=key)
                session.add(k)
                new_articel.schlagworter.append(k)

            session.add(new_articel)
            session.commit()

            entry = Wikipedia_Entry(title,
                                    latitude,
                                    longitude,
                                    types,
                                    distance,
                                    keywords,
                                    page_ID,
                                    image,
                                    opening_hours,
                                    address,
                                    url
                                    )

        articles.append(entry.toDict())
    session.close()
    if userID:
        articles = sorted(articles,
                          key=lambda article: calculateLikes(article.get('type'),
                                                             userID, session,
                                                             article.get('distance')))
    return Response({'notes': articles}, 200).response()


@app.route('/get/details/<pageid>', methods=['GET'])
def getDetails(pageid):
    '''
    Return Json Object with Status, Errors and summary of given page.

    If not object is found it returns a 404.
    '''
    session = DBSession()
    try:

        artikel = session.query(Artikel).filter(
            Artikel.pageWikiId == pageid
            ).one()
        if artikel.summary:
            summary = artikel.summary
        else:
            summary = wikipedia.summary(artikel.title)
            artikel.summary = summary
            session.add(artikel)
            session.commit()
    except NoResultFound:
        return Response(None, 404).response()
    session.close()
    return Response({'summary': summary}, 200).response()


@app.route('/get/userID/', methods=['GET'])
def getUserID():
    session = DBSession()
    new_user = User()
    session.add(new_user)
    session.commit()
    userid = new_user.id
    session.close()
    return Response({'userID': userid}, 200).response()


@app.route('/post/user/profile/<pageid>/<userID>', methods=['POST'])
def setUserInfo(pageid, userID):
    try:
        userID = int(userID)
        pageid = int(pageid)

        time = int(request.args.get('time', 0))
    except ValueError:
        return Response("You Sir, fucked up", 400).response()
    session = DBSession()
    liked = request.args.get('liked', True)
    if liked == "true":
        liked = True
    else:
        liked = False

    try:
        article = session.query(Artikel).filter(
            Artikel.pageWikiId == pageid
            ).one()
        user = session.query(User).filter(User.id == userID).one()
        try:
            bewertung = session.query(PersonalizedArtikel).filter(
                PersonalizedArtikel.user == user
                ).filter(
                PersonalizedArtikel.artikel_id == pageid
                ).one()

            if bewertung.liked != liked:
                bewertung.liked = liked
                session.add(bewertung)

        except NoResultFound:
            bewertung = PersonalizedArtikel(user=user,
                                            artikel=article,
                                            liked=liked,
                                            counter=0)

            session.add(bewertung)
        try:
            ratingCategory = session.query(Rating).filter(
                Rating.user_id == userID
                ).filter(
                article.gattung == Rating.categoryName
                ).one()
        except NoResultFound:
            ratingCategory = Rating(user_id=userID,
                                    categoryName=article.gattung,
                                    likes=0,
                                    dislikes=0,
                                    totalLikeTime=0)
        if liked:
            ratingCategory.likes += 1
            ratingCategory.totalLikeTime = ratingCategory.totalLikeTime + time
        else:
            ratingCategory.dislikes += 1
        session.add(ratingCategory)
        session.commit()
    except NoResultFound:
        session.close()
        return Response("You will remember the day where you almost passed a valid User ID/Wiki ID", 404).response()

    session.close()
    return Response({'response': "well, this works"}, 200).response()


@app.errorhandler(404)
def page_not_found(error):
    return Response("You shall not find what you are looking for", 404).response()

if __name__ == '__main__':
    mysqlhost = '127.0.0.1'
    mysqlport = 3306
    mysqluser = 'root'
    mysqlpassword = 'asdf1234'
    mysqldb = 'kolumbus'
    engine = create_engine("mysql+pymysql://{0}:{1}@{2}/{3}?charset=utf8"
                           .format(mysqluser,
                                   mysqlpassword,
                                   mysqlhost,
                                   mysqldb),
                           encoding='utf-8', echo=False)
    Base.metadata.create_all(engine)
    package_directory = os.path.dirname(os.path.abspath(__file__))
    #logging.basicConfig(filename=package_directory+'/logs/kolumbus-server.log',
    #                    level=logging.DEBUG)

    #logging.info("Connected to mysql on {0}:{1}/{2}".format(
    #    mysqlhost, mysqlport, mysqldb))
    DBSession = sessionmaker(bind=engine)
    # app.register_error_handler(Exception, error_handler)
    app.run(debug=True, host='0.0.0.0')
