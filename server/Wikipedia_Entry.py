from sqlalchemy.orm.exc import NoResultFound
from sqlalchemy_declarative import Artikel


class Wikipedia_Entry():

    def __init__(self, name, latitude, longditude, type, distance,
                 schlagworte, pageid, imageurl, opening_hours, address):
        self.name = name
        self.latitude = latitude,
        self.longditude = longditude,
        self.type = type
        self.distance = distance
        self.schlagworte = schlagworte
        self.pageid = pageid
        self.imageurl = imageurl
        self.opening_hours = opening_hours
        self.address = address

    @classmethod
    def fromWikiID(cls, pageid, distance, session):
        try:
            artikel = session.query(Artikel).filter(Artikel.pageWikiId == pageid).one()
            cls(artikel.title,
                artikel.latitude,
                artikel.longditude,
                artikel.type,
                distance,
                artikel.schlagworte,
                artikel.pageid,
                artikel.imageurl,
                artikel.opening_hours,
                artikel.address)
        except NoResultFound:
            return None

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': {'lat':self.latitude, 'lon': self.longditude},
            'type': self.type,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid,
            'imageurl': self.imageurl,
            'opening_hours': self.opening_hours,
            'address': self.address
        }
        return dictionary