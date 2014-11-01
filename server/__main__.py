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
    def __init__(self, name, gps, typ, distance, image, schlagworte, pageid):
        self.name = name
        self.gps = gps
        self.typ = typ
        self.schlagworte = schlagworte
        self.image = image
        self.pageid = pageid

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'type': self.typ,
            'imageurl': self.image,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid
        }
        return dictionary

class Wikipedia_Entry():
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
    r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
    try:
        placeID = r['results'][0]['place_id']
        r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
        result = {}
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
        return result
    except IndexError:
        result['types'] = None
        result['open_now'] = None
        result['opening_times'] = None


def geosearch(latitude, longtitude, gtype,radius): 
    return apicall('en', 'query', 'json', "&type={0}&gsradius={3}&gscoord={1}|{2}&list=geosearch".format(gtype, latitude,longtitude,radius)).get('query').get('geosearch')


def getImage(page_IDs):
    page_IDs = "|".join(page_IDs)
    response= apicall('en', 'query', 'json', "&prop=pageimages&inprop=url&pageids={0}&pithumbsize=600".format(page_IDs)).get('query')

    for page in response.get('pages'):
        image = response.get('pages').get(page).get('thumbnail').get('source')
    return image


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


@app.route('/get/articles/pushNotification/<latitude>/<longtitude>')
def getPushLocations(latitude, longtitude):
    articles = []
    radius = request.args.get('radius', 1000)
    userID = request.args.get('userID')
    for article in geosearch(latitude, longtitude, 'landmark', radius):
        if len(articles) > 5:
            break
        print(request.args)
        title = article.get('title')
        latitude = article.get('lat')
        longtitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')


        image = getImage([str(page_ID)])
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
                                         image,
                                         keywords,
                                         page_ID)

        articles.append(entry.toDict())
    return jsonify({'notes': articles}), 200


@app.route('/get/articles/<latitude>/<longtitude>')
def getLocations(latitude, longtitude, **kwargs):
    articles = []
    radius = request.args.get('radius', 1000)
    userID = request.args.get('userID')
    for article in geosearch(latitude, longtitude, 'landmark', radius):
        if len(articles) > 5:
            break
        title = article.get('title')
        latitude = article.get('lat')
        longtitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')

        #check if artikel has been loaded already
        

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
        types = googleResults.get('types')
        opening_hours = googleResults.get('opening_times'),
        open_now = googleResults.get('opening_now')

        # Wiki Api
        image = getImage([str(page_ID)])
        page = wikipedia.page(title, auto_suggest=True, redirect=False)

        # Alchemy Api
        keywords = getSchlagworter(page.title, page.url)


        entry = Wikipedia_Entry(title,
                        {'lat': latitude,
                         'lon': longtitude},
                        types,
                        distance,
                        keywords,
                        page_ID,
                        image,
                        opening_hours,
                        open_now
                        )

        articles.append(entry.toDict())
    return jsonify({'notes': articles})
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

