import requests
import json
import wikipedia

def getSchlagworter(content):
    r = requests.get('https://api.idolondemand.com/1/api/sync/extractconcepts/v1?text={0}&apikey=f0438796-6744-4ca2-9923-34605b45b713'.format(content))
    if not r.status_code == requests.codes.ok:
    	return []
    z = r.json()
        
    return z['concepts'].fetch(10)

getSchlagworter('Das Mercedes-Benz-Museum befand sich bis zum 18. März 2006 auf dem Gelände des Mercedes-Benz-Werkes')
