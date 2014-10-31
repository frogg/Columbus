import requests
import json
import wikipedia

def getSchlagworter(content):
    r = requests.get('https://api.idolondemand.com/1/api/sync/extractconcepts/v1?text='+content+'&apikey=f0438796-6744-4ca2-9923-34605b45b713')
    # print(r.status_code)
    z = r.json()
    # z.get('concepts')
    for i in z['concepts']:
        print(i['concept'])

    print("sdfsad")
    return "sdfsad"

getSchlagworter('Das Mercedes-Benz-Museum befand sich bis zum 18. März 2006 auf dem Gelände des Mercedes-Benz-Werkes')
