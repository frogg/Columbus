import wikipedia
import json
import requests
import hashlib
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

from Wikipedia_Entry import Wikipedia_Entry

app = Flask(__name__)


@app.route('/')
def readme():
    with open ("README.md", "r") as myfile:
        content = myfile.read()
        content = Markup(markdown.markdown(content))
    return render_template('index.html', **locals())


def getPlacesAtLocation(lattitude, longitude, radius, types):
    try:
        types = "|".join(types)
        result = {}
        shittyHardcodedBlacklist = ["establishment"]
        shittyHardcodedTierlist1 = [""]
        shittyHardcodedTierlist2 = [""]
        shittyHardcodedTierlist3 = [""]
        try:
            r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            #r = requests.get('https://maps.googleapis.com/maps/api/place/textsearch/json?query=bw+bank+stuttgart&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            placeID = r['results'][0]['place_id']
            r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            
            try:
                result['address'] = r['result']['formatted_address']
            except:
                result['address'] = None

            try:
                typeReturn2 = None
                typeReturn3 = None
                for x in r['result']['types']:
                    if x not in shittyHardcodedBlacklist:
                        if x in shittyHardcodedTierlist1:
                            result['types'] = x
                            break
                        if x in shittyHardcodedTierlist2:
                            if typeReturn2 == None:
                                typeReturn2 = x
                        if x in shittyHardcodedTierlist3:
                            if typeReturn3 == None:
                                typeReturn3 = x
                    if typeReturn2 == None:
                        if typeReturn3 == None:
                            result['types'] = None
                        else:
                            result['types'] = typeReturn3
                    else: 
                        result['types'] = typeReturn2



            except KeyError:
                result['types'] = None
            try:
                if r['result']['opening_hours']['open_now']:
                    result['open_now'] = r['result']['opening_hours']['open_now']
                else:
                    result['open_now'] = False

                result['opening_times'] = {'mon': [None, None, None, None],
                                           'tue': [None, None, None, None],
                                           'wed': [None, None, None, None],
                                           'thu': [None, None, None, None],
                                           'fri': [None, None, None, None],
                                           'sat': [None, None, None, None],
                                           'sun': [None, None, None, None]}
                for row in r['result']['opening_hours']['periods']:
                    if row['open']['day'] == 0:
                        day = 'sun'
                    elif row['open']['day'] == 1:
                        day = 'mon'
                    elif row['open']['day'] == 2:
                        day = 'tue'
                    elif row['open']['day'] == 3:
                        day = 'wed'
                    elif row['open']['day'] == 4:
                        day = 'thu'
                    elif row['open']['day'] == 5:
                        day = 'fri'
                    elif row['open']['day'] == 6:
                        day = 'sat'

                    if result['opening_times'][day][0] != None:
                        tempclosing = result['opening_times'][day][3]
                        tempopening = result['opening_times'][day][0]
                        result['opening_times'][day] = [tempopening, tempclosing, row["open"]["time"], row["close"]["time"]]
                    else:
                        result['opening_times'][day] = [row["open"]["time"], None, None, row["close"]["time"]]
    
            except KeyError as e:
                print ("Error found:")
                print (e)
                result['open_now'] = None
                result['opening_times'] = None
        except IndexError as e:
            print (e)
            result['types'] = None
            result['open_now'] = None
            result['opening_times'] = None
        return result
    except ConnectionError as e:
        return None



def geosearch(latitude, longitude, gtype,radius): 
    return apicall('en', 'query', 'json', "&type={0}&gsradius={3}&gscoord={1}|{2}&list=geosearch".format(gtype, latitude,longitude,radius)).get('query').get('geosearch')


def getImage(page_IDs):
    page_IDs = "|".join(page_IDs)
    response= apicall('en', 'query', 'json', "&prop=pageimages&inprop=url&pageids={0}&pithumbsize=600".format(page_IDs)).get('query')
    try:
        for page in response.get('pages'):
            
            image = response.get('pages').get(page).get('thumbnail').get('source')
            if "logo" in image or ".svg" in image or "Logo" in image:
                imagename = response.get('pages').get(page).get('pageimage').replace('_', ' ')
                for name in getListofImagesForPage(page_IDs):
                    if imagename in name.get('title'):
                        continue
                    image = calculateWikimediaFilePath(name.get('title'))
        return image
    except AttributeError:
        return None


def calculateWikimediaFilePath(filename):
    url = "http://upload.wikimedia.org/wikipedia/commons/"
    filename = filename.replace(" ","_").split(':')[1]
    m = hashlib.md5()
    m.update(filename.encode('utf-8'))
    md5sum = m.hexdigest()
    return url+md5sum[:1]+"/"+md5sum[:2]+"/"+filename


def getListofImagesForPage(page_IDs):
    image_names = []
    response= apicall('en', 'query', 'json', "&prop=imageinfo|images&inprop=url&pageids={0}".format(page_IDs)).get('query')
    for page in response.get('pages'):
        for image in response.get('pages').get(page).get('images'):
            image_names.append(image)
    return image_names

def apicall(language, action, response_format, specialValues):
    url = "https://{0}.wikipedia.org/w/api.php?action={1}&format={2}{3}".format(language,action,response_format,specialValues)
    print(url)
    r = requests.get(url)
    r = r.json()
    return r


def getSchlagworter(title, url):
    r = requests.get('http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&url={0}&outputMode=json&maxRetrieve=7'.format(url))
    if not r.status_code == requests.codes.ok:
        return []
    z = r.json()
    count = 0
    keywords= []
    for word in z['keywords']:
        if count < 5:
            if title in word['text']:
                print("It's there!!!")
                count+= 1
            else:
                keywords.append(word['text'])
        else:
            keywords.append(word['text'])
    return keywords[:5]


@app.route('/get/articles/<latitude>/<longitude>')
def getLocations(latitude, longitude, **kwargs):
    articles = []
    radius = request.args.get('radius', 1000)
    userID = request.args.get('userID')
    databaseQueryAllArticels = session.query(Artikel).all()
    for article in geosearch(latitude, longitude, 'landmark', radius):
        if len(articles) > 50:
            break
        title = article.get('title')
        latitude = article.get('lat')
        longitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')
        #url = TBD

        #check if article has been loaded already => lade article_datenbank
        alreadyLoaded = False
        for article_datenbank in databaseQueryAllArticels:
            if article_datenbank.pageWikiId == page_ID:
                alreadyLoaded = True;
                opening_hours = json.loads(article_datenbank.offnungszeiten)
                types = article_datenbank.gattung
                image = article_datenbank.picUrl
                address = article_datenbank.address
                keywords = []
                for wort in article_datenbank.schlagworter:
                    keywords.append(wort.text)

        #article isn#t stored already => load Data and save to DataBase
        if not alreadyLoaded:

             # Google Api
            allowedtypes = [
                'museum',
                'aquarium',
                'art_gallery',
                'book_store',
                'cemetery',
                'church'
                'city_hall',
                'hindu_temple',
                'library',
                'museum',
                'place_of_worship',
                'stadium',
                'university',
                'zoo']
            googleResults = getPlacesAtLocation(latitude, longitude, radius, allowedtypes)
            types = googleResults.get('types')
            opening_hours = googleResults.get('opening_times'),
            address = googleResults.get('address')
            # Wiki Api
            image = getImage([str(page_ID)])
            page = wikipedia.page(title, auto_suggest=True, redirect=False)

            # Alchemy Api
            keywords = getSchlagworter(page.title, page.url)
            new_articel = Artikel(address= address, latitude= latitude, longitude=longitude, pageWikiId = page_ID, gattung = types, offnungszeiten = json.dumps(opening_hours), title = title, url = page.url, picUrl = image)
            for key in keywords:
                k = Schlagwort(text = key)
                session.add(k)
                new_articel.schlagworter.append(k)            

            session.add(new_articel)
            session.commit()

        entry = Wikipedia_Entry(title,
                                {'lat': latitude,
                                 'lon': longitude},
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
    try:
        artikel = session.query(Artikel).filter(Artikel.pageWikiId == pageid).one()
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
    new_user = User(lastLogin = datetime.datetime.now())
    session.add(new_user)
    session.commit()
    return jsonify({'userID':new_user.id})

@app.route('/post/user/profile/<pageid>/<userID>')
def setUserInfo(pageid, userID):
    liked=request.args.get('liked', True)
    user = session.query(User).filter(User.id == userID).one()
    bereitsVorhanden = False
    for pArtikel in session.query(PersonalizedArtikel).filter(PersonalizedArtikel.user == user).all():
        if(pArtikel.artikel.pageWikiId == pageid):
            bereitsVorhanden = True
            pArtikel.liked = False

    if not bereitsVorhanden:
        article = session.query(Artikel).filter(Artikel.pageWikiId == pageid).one()
        paritkel = PersonalizedArtikel(user=user, artikel=article, liked = liked, counter = 0)

    session.add(paritkel)
    session.commit()
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
                       .format(mysqluser, mysqlpassword, mysqlhost, mysqldb),
                       encoding='utf-8', echo=False)
    Base.metadata.create_all(engine)
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    app.run(debug=True, host='0.0.0.0')

def calculateLikes(likes, dislikes, totalLikeTime):

    likeMultiplier = 4
    if isinstance(likes, int) and isinstance(dislikes, int) and isinstance(totalLikeTime, int):
        totalVotes = likes + dislikes
        averageTime = totalLikeTime / totalVotes
        timeLikes = totalLikeTime / (averageTime*likeMultiplier)
        print (timeLikes)
        totalLikes = (likes + timeLikes - dislikes)*20
        if totalLikes > 1000:
            totalLikes = 1000
        return totalLikes
    else:
        return None
