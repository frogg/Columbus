import wikipedia
import json

import markdown
import math

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
from Wikipedia_Entry import Wikipedia_Entry

app = Flask(__name__)


@app.route('/')
def readme():
    with open("README.md", "r") as myfile:
        content = myfile.read()
        content = Markup(markdown.markdown(content))
    return render_template('index.html', **locals())


@app.route('/get/articles/<latitude>/<longitude>')
def getLocations(latitude, longitude, **kwargs):
    session = DBSession()
    articles = []
    radius = request.args.get('radius', 1000)

    for article in geosearch(latitude, longitude, 'landmark', radius):
        if len(articles) > 50:
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
                                                radius)
            types = googleResults.get('types')
            opening_hours = googleResults.get('opening_times'),
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
                                    address
                                    )

        articles.append(entry.toDict())
    return jsonify({'notes': articles})


@app.route('/get/details/<pageid>')
def getDetails(pageid):
    '''
    Return Json Object with Status, Errors and summary of given page.

    If not object is found it returns a 404.
    '''
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
        return "Error", 404

    return jsonify({'summary': summary})


@app.route('/get/userID/')
def getUserID():
    new_user = User()
    session.add(new_user)
    session.commit()
    return jsonify({'userID': new_user.id})


@app.route('/post/user/profile/<pageid>/<userID>')
def setUserInfo(pageid, userID):
    liked = request.args.get('liked', True)
    try:
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
            article = session.query(Artikel).filter(
                Artikel.pageWikiId == pageid
                ).one()
            paritkel = PersonalizedArtikel(user=user,
                                           artikel=article,
                                           liked=liked,
                                           counter=0)

            session.add(paritkel)
        session.commit()
    except NoResultFound:
        return 404
    return jsonify({'sucess': True})


@app.errorhandler(404)
def page_not_found(error):
    return "Page not found", 404

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
    DBSession = sessionmaker(bind=engine)
    app.run(debug=True, host='0.0.0.0')
