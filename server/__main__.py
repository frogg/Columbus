import wikipedia
import json
import requests
from flask import Flask, jsonify
app = Flask(__name__)
@app.route('/')
def hi():
    return "hey"

class pushNotificationResponse():
    def __init__(self, name, gps, typ, distance, schlagworte, requestid, pageid):
        self.name = name
        self.gps = gps
        self.typ = typ
        self.schlagworte = schlagworte
        self.requestid = requestid
        self.pageid = pageid

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'typ': self.typ,
            'schlagworte': self.schlagworte,
            'requestid': self.requestid,
            'pageid': self.pageid
        }
        return dictionary

class location():
    def __init__(self, name, gps, typ, distance, schlagworte, requestid, pageid, imageurl,oeffnungszeiten):
        self.name = name
        self.gps = gps
        self.typ = typ
        self.distance = distance
        self.schlagworte = schlagworte
        self.requestid = requestid
        self.pageid = pageid
        self.imageurl = imageurl
        self.oeffnungszeiten = oeffnungszeiten
    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'typ': self.typ,
            'schlagworte': self.schlagworte,
            'requestid': self.requestid,
            'pageid': self.pageid,
            'imageurl': self.imageurl,
            'oeffnungszeiten': self.oeffnungszeiten
        }
        return dictionary

def geosearch(latitude, longtitude, gtype,radius): 
    return apicall('en','query','json','geosearch',"&type={0}&gsradius={3}&gscoord={1}|{2}".format(gtype, latitude,longtitude,radius))

def getSite(siteID):

    pass

def apicall(language, action, response_format, listParams, specialValues):
    r = requests.get("https://{0}.wikipedia.org/w/api.php?action={1}&format={2}&list={3}{4}".format(language,action,response_format,listParams,specialValues))
    r = r.json().get('query').get('geosearch')
    return r

def getSchlagworter(title, url):
    test = "http://en.wikipedia.org/wiki/Mercedes-Benz";
    r = requests.get('http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&url={0}&outputMode=json&maxRetrieve=10'.format(test))
    if not r.status_code == requests.codes.ok:
        return []
    z = r.json()
    z = 0
    keywords= []
    for word in z['keywords']:
        if z < 5:
            if title in word['text']:
                print("It's there!!!")
                z+= 1
            else:
                keywords.append(word['text'])
        else:
            keywords.append(word['text'])
    return keywords

@app.route('/get/locations/pushNotification/<latitude>/<longtitude>')
def getPushLocations(latitude, longtitude):
    locations = []
    for i in geosearch(latitude, longtitude, 'landmark',1000):
        if len(locations)>5:
            break
        entry =pushNotificationResponse(i.get('title'),
                                        {'lat':i.get('lat'),
                                         'lon':i.get('lon')}, 
                                         "typ", 
                                         i.get('dist'), 
                                         "test",
                                         "stuff",
                                         i.get('pageid'))

        locations.append(entry.toDict())
    return jsonify({'notes':locations}), 200

@app.route('/get/locations/<latitude>/<longtitude>')
def getLocations(latitude, longtitude):
    locations = []
    for i in geosearch(latitude, longtitude, 'landmark', 1000):
        if len(locations)>5:
            break
        entry = location(i.get('title'),
                         {'lat': i.get('lat'),
                          'long': i.get('long')},
                         "typ",
                         i.get('dist'),
                         "test",
                         getSchlagworter(wikipedia.summary(i.get('title'))),
                         i.get('pageid'),
                         "http://upload.wikimedia.org/wikipedia/commons/1/1a/Mercedes-Benz_Museum_201312_02_sunset.jpg",
                         'oeffnungszeiten')

        locations.append(entry.toDict())
<<<<<<< HEAD

    return jsonify({'notes':locations})
'''
@app.route('/get/userID')
def pushLocations(latitude, longtitude):
    return wikipedia.geosearch(latitude, longtitude)
    return 'Hello World!'
=======
    for location in locations:
        getSite(location.pageid)
    return "sutff"
>>>>>>> 8fac7da4311521b98dc39c8b03900105e171f683


@app.route('/get/userID')
def getUserID():
    return "QUAPPI RULES"
    
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