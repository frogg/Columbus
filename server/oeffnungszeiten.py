import requests
import json

def getPlacesAtLocation(lattitude, longitude, radius, types):

	r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()

	placeID = r['results'][0]['place_id']

	r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyAd_yIgEyAddkiGQQapy-Cxo2BypNGdsNo').json()
	result = {}
	result['types'] = r['result']['types']
	if r['result']['opening_hours']:
		result['open_now'] = r['result']['opening_hours']['open_now']
		result['opening_times'] =  r['result']['opening_hours']['periods']
	else:
		result['open_now'] = None
		result['opening_times'] = None
	return result