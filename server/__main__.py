import wikipedia
import json
import requests
import sql

from flask import Flask, jsonify
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

def getPlacesAtLocation(lattitude, longitude, radius, types, name):
    types = "|".join(types)
    r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&name='+name+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
    try:
        placeID = r['results'][0]['place_id']
        r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
        result = {}
        result['types'] = r['result']['types']
        if r['result']['opening_hours']:
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

        else:
            result['open_now'] = None
            result['opening_times'] = None
        return result
    except IndexError:
        return None


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
    for article in geosearch(latitude, longtitude, 'landmark', 1000):
        if len(locations) > 5:
            break
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
        googleResults = getPlacesAtLocation(latitude, longtitude, 1000, allowedtypes)
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
    for article in geosearch(latitude, longtitude, 'landmark', 1000):
        if len(locations) > 5:
            break
        if not kwargs.get('radius'):
            radius = 1000
        title = article.get('title')
        latitude = article.get('lat')
        longtitude = article.get('lon')
        distance = article.get('dist')
        page_ID = article.get('pageid')

        # Google Api
        googleResults = getPlacesAtLocation(latitude, longtitude, radius, 'museum')
        types = googleResults.get('types')
        opening_hours = googleResults.get('opening_times'),
        open_now = googleResults.get('opening_now')

        # Wiki Api
        images = getImages(page_ID)
        page = wikipedia.page(title, auto_suggest=True, redirect=False)

        # Alchemy Api
        keywords = getSchlagworter(page.title, page.url)

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


@app.route('/get/userID')
def getUserID():
    return "QUAPPI RUL€ZZZ"
    
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
    app.run(debug=True, host='0.0.0.0')