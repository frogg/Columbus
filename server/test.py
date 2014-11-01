import requests
import json
import wikipedia

def getSchlagworter(content):
    r = requests.get('http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&url=http://en.wikipedia.org/wiki/Mercedes-Benz&outputMode=json&maxRetrieve=10')
    z = r.json()
    #print(z)
    # z.get('concepts')
    z = 0
    for i in z['keywords']:
        if z < 5
            if "Mercedes-Benz" in i['text']:
                print("It's there!!!")
            else:
                print(i['text'])
        else 

    print("sdfsad")

getSchlagworter('Test')
