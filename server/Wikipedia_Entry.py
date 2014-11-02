import json

from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy_declarative import Artikel


class Wikipedia_Entry():

    def __init__(self, name, latitude, longitude, type, distance,
                 schlagworte, pageid, imageurl, opening_hours, address, url):
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.type = type
        self.distance = distance
        self.schlagworte = schlagworte
        self.pageid = pageid
        self.imageurl = imageurl
        self.opening_hours = opening_hours
        self.address = address
        self.url = url

    @classmethod
    def fromWikiID(cls, pageid, distance, session):
        try:
            artikel = session.query(Artikel).filter(
                Artikel.pageWikiId == pageid).one()
            schlagworter = []
            for wort in artikel.schlagworter:
                schlagworter.append(wort.text)
            return cls(artikel.title,
                       artikel.latitude,
                       artikel.longitude,
                       artikel.gattung,
                       distance,
                       schlagworter,
                       artikel.pageWikiId,
                       artikel.picUrl,
                       json.loads(artikel.offnungszeiten),
                       artikel.address,
                       artikel.url)
        except NoResultFound:
            return None

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': {'lat': self.latitude, 'lon': self.longitude},
            'type': self.type,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid,
            'imageurl': self.imageurl,
            'opening_hours': self.opening_hours,
            'address': self.address,
            'distance': self.distance,
            'url': self.url
        }
        return dictionary
