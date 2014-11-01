class Wikipedia_Entry():
    def __init__(self, name, gps, type, distance, schlagworte, pageid, imageurl, opening_hours, address):
        self.name = name
        self.gps = gps
        self.type = type
        self.distance = distance
        self.schlagworte = schlagworte
        self.pageid = pageid
        self.imageurl = imageurl
        self.opening_hours = opening_hours
        self.address = address

    def toDict(self):
        dictionary = {
            'name': self.name,
            'gps': self.gps,
            'type': self.type,
            'schlagworte': self.schlagworte,
            'pageid': self.pageid,
            'imageurl': self.imageurl,
            'opening_hours': self.opening_hours,
            'address': self.address
        }
        return dictionary