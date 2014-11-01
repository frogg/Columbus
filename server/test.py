import requests
import json
import wikipedia

def getSchlagworter(content):
    r = requests.get('http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&url=http://en.wikipedia.org/wiki/Mercedes-Benz&outputMode=json&maxRetrieve=20')
    '''r = requests.get('http://access.alchemyapi.com/calls/text/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&text="HelloHelloMamatest120sadfa"&outputMode=json&maxRetrieve=5')'''
    z = r.json()
    print(z)
    # z.get('concepts')
    for i in z['keywords']:
        print(i['text'])

    print("sdfsad")

getSchlagworter('Test')
