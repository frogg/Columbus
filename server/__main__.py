import wikipedia
import json
import requests
from flask import Flask, jsonify, request
import sql
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy_declarative import *

app = Flask(__name__)
@app.route('/')
def hi():
    return "hey"

class pushNotificationResponse():
    def __init__(self, name, gps, typ, distance, schlagworte, pageid):
        self.name = name
        self.gps = gps
        self.typ = typ
        self.schlagworte = schlagworte
        self.pageid = pageid

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'typ': self.typ,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid
        }
        return dictionary

class location():
    def __init__(self, name, gps, type, distance, schlagworte, pageid, imageurl, opening_hours, open_now):
        self.name = name
        self.gps = gps
        self.type = type
        self.distance = distance
        self.schlagworte = schlagworte
        self.pageid = pageid
        self.imageurl = imageurl
        self.opening_hours = opening_hours
        self.open_now = open_now

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'type': self.type,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid,
            'imageurl': self.imageurl,
            'opening_hours': self.opening_hours,
            'open_now': self.open_now
        }
        return dictionary

def getPlacesAtLocation(lattitude, longitude, radius, types):
    types = "|".join(types)
    result = {}
    try:
        r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
        placeID = r['results'][0]['place_id']
        r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
        try:
            result['types'] = r['result']['types']
        except KeyError:
            result['types'] = None
        try:
            if r['result']['opening_hours']['open_now']:
                result['open_now'] = r['result']['opening_hours']['open_now']
            else:
                result['open_now'] = False
            result['opening_times'] = r['result']['opening_hours']['periods']
            result['opening_times'] = {'mon': [1000, None, None, 1700],
                                       'tue': [1000, None, None, 1700],
                                       'wen': [1000, None, None, 1700],
                                       'thu': [1000, None, None, 1700],
                                       'fri': [1000, None, None, 1700],
                                       'sat': [1000, None, None, 1700],
                                       'sun': [1000, None, None, 1700]}
        except KeyError:
            result['open_now'] = None
            result['opening_times'] = None
    except IndexError:
        result['types'] = None
        result['open_now'] = None
        result['opening_times'] = None
    return result


def geosearch(latitude, longtitude, gtype,radius): 
    return apicall('en', 'query', 'json', "&type={0}&gsradius={3}&gscoord={1}|{2}&list=geosearch".format(gtype, latitude,longtitude,radius)).get('query').get('geosearch')


def getImages(pageid):
    images = []

    response= apicall('commons', 'query', 'json', "&pageids={0}&prop=imageinfo&iiprop=url".format(pageid)).get('query')
    for page in response.get('pages'):
        for image in response.get('pages').get(page).get('imageinfo'):
            images.append(image.get('url'))
    return images


def apicall(language, action, response_format, specialValues):
    r = requests.get("https://{0}.wikipedia.org/w/api.php?action={1}&format={2}{3}".format(language,action,response_format,specialValues))
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


@app.route('/get/locations/pushNotification/<latitude>/<longtitude>')
def getPushLocations(latitude, longtitude):
    locations = []
    radius = request.args.get('radius', 1000)
    userID = request.args.get('userID')
    for article in geosearch(latitude, longtitude, 'landmark', radius):
        if len(locations) > 5:
            break
        print(request.args)
        title = article.get('title')
        latitude = article.get('lat')
        longtitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')

        # Google Places APi
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
        googleResults = getPlacesAtLocation(latitude, longtitude, radius, allowedtypes)
        types = googleResults.get('types')

        #Wiki Api
        page = wikipedia.page(title, auto_suggest=True, redirect=False)

        #Alchemy Api
        keywords = getSchlagworter(page.title, page.url)

        entry = pushNotificationResponse(title,
                                         {'lat': latitude,
                                          'lon': longtitude},
                                         types,
                                         distance,
                                         keywords,
                                         page_ID)

        locations.append(entry.toDict())
    return jsonify({'notes': locations}), 200


@app.route('/get/locations/<latitude>/<longtitude>')
def getLocations(latitude, longtitude, **kwargs):
    locations = []
    radius = request.args.get('radius', 1000)
    userID = request.args.get('userID')
    for article in geosearch(latitude, longtitude, 'landmark', radius):
        if len(locations) > 5:
            break
        title = article.get('title')
        latitude = article.get('lat')
        longtitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')
        #url = TBD

        #check if article has been loaded already => lade article_datenbank
        alreadyLoaded = false
        for article_datenbank in session.query(Artikel).all():
            if article_datenbank.pageWikiId == page_ID:
                alreadyLoaded = true;
                opening_hours = jsonify({'opening_hours': article_datenbank.offnungszeiten})
                gattung = article_datenbank.gattung
                #open_now = TO BE CALCULATED FROM OPENING HOURS
                image = article_datenbank.picUrl
                #keywords liste

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
            googleResults = getPlacesAtLocation(latitude, longtitude, radius, allowedtypes)
            #types = googleResults.get('types')
            gattung = "MuseumTBD"
            opening_hours = googleResults.get('opening_times'),
            open_now = googleResults.get('opening_now')

            # Wiki Api
            images = getImages(page_ID)
            image = "TBD"
            page = wikipedia.page(title, auto_suggest=True, redirect=False)

            # Alchemy Api
            keywords = getSchlagworter(page.title, page.url)

            new_articel = Artikel(pageWikiId = page_ID, gattung = gattung, offnungszeiten = opening_hours, title = title, url = page, picUrl = image)
            for key in keywords:
                k = Schlagwort(text = key)
                session.add(k)
                new_articel.schlagworter.append(k)            

            session.add(new_articel)
            session.commit()
        

        entry = location(title,
                         {'lat': latitude,
                          'lon': longtitude},
                         types,
                         distance,
                         keywords,
                         page_ID,
                         images,
                         opening_hours,
                         open_now
                         )

        locations.append(entry.toDict())
    return jsonify({'notes': locations})


@app.route('/get/details/<pageid>')
def getDetails(pageid):
    
    return "Not read yet"

@app.route('/get/userID/')
def getUserID():
    new_user = User(lastLogin = datetime.datetime.now())
    session.add(new_user)
    session.commit()
    return jsonify({'userID':new_user.id})
    
'''
@app.route('/get/Info/<latitude>/<longtitude>')
def pushLocations(latitude, longtitude):
    return wikipedia.geosearch(latitude, longtitude)
    return 'Hello World!'
'''
@app.errorhandler(404)
def page_not_found(error):
    return "Page not found", 404

if __name__ == '__main__':
    engine = create_engine('sqlite:///database.db')
    Base.metadata.create_all(engine)
    DBSession = sessionmaker(bind=engine)
    session = DBSession()
    app.run(debug=True, host='0.0.0.0')

