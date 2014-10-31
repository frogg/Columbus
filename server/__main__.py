import wikipedia
import json
import requests
from flask import Flask, jsonify
app = Flask(__name__)
@app.route('/')
def hi():
    return "hey"

class pushNotificationResponse():
    def __init__(self, name, gps, typ, distance, schlagworte, requestid):
        self.name = name
        self.gps = gps
        self.typ = typ
        self.schlagworte = schlagworte
        self.requestid = requestid

    def toDict(self):
        json = {
            'name': self.name,
            'gps': self.gps,
            'typ': self.typ,
            'schlagworte': self.schlagworte,
            'requestid': self.requestid
        }
        return json

def geosearch(latitude, longtitude, format):
    r = requests.get("https://en.wikipedia.org/w/api.php?action=query&format=json&gsprop=type&type=landmark&list=geosearch&gsradius=10000&gscoord=37.786971|-122.399677")
    r = r.json().get('query').get('geosearch')
    return r

@app.route('/get/locations/pushNotification/<latitude>/<longtitude>')
def getPushLocations(latitude, longtitude):
    locations = []
    for i in geosearch(latitude, longtitude, 'json'):
        if len(locations)>5:
            break
        entry =pushNotificationResponse(i.get('title'),
                                        {'lat':i.get('lat'),
                                         'long':i.get('long')}, 
                                         "typ", 
                                         i.get('dist'), 
                                         "stuff",
                                         "stuff")
        locations.append(entry.toDict())
    return jsonify({'notes':locations}), 200

@app.route('/get/locations/<latitude>/<longtitude>')
def pushLocations(latitude, longtitude):
    return wikipedia.geosearch(latitude, longtitude)
    return 'Hello World!'
'''
@app.route('/get/userID')
def pushLocations(latitude, longtitude):
    return wikipedia.geosearch(latitude, longtitude)
    return 'Hello World!'

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