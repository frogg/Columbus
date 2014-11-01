import os
import sys
#from sqlalchemy import Column, ForeignKey, Integer, String, Boolean, Double Trick:
from sqlalchemy import *
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import create_engine
import datetime
from sqlalchemy.types import DateTime
from sqlalchemy.ext.orderinglist import ordering_list



Base = declarative_base()
 
class User(Base):
    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    lastLogin = Column(DateTime(timezone=True), primary_key=False, nullable=False, default=datetime.datetime.now())
    

class Artikel(Base):
    __tablename__ = 'artikel'
    id = Column(Integer, primary_key=True)
    pageWikiId = Column(Integer)
    latitude = Column(Float)
    longitude = Column(Float)
    gattung = Column(String(50))
    schlagworter = relationship('Schlagwort', backref='artikel',
                            collection_class=ordering_list('position'),
                            order_by='Schlagwort.position')
    picUrls = relationship('PicUrl', backref='artikel',
                            collection_class=ordering_list('position'),
                            order_by='PicUrl.position')
    offnungszeiten = Column(String(50))
    url = Column(String(50))
    title = Column(String(50))



class Schlagwort(Base):
    __tablename__ = 'schlagwort'
    id = Column(Integer, primary_key=True)
    slide_id = Column(Integer, ForeignKey('artikel.id'))
    position = Column(Integer)
    text = Column(String)

    def __repr__(self):
        return str(self.id)+self.text

class PicUrl(Base):
    __tablename__ = 'picUrl'
    id = Column(Integer, primary_key=True)
    slide_id = Column(Integer, ForeignKey('artikel.id'))
    position = Column(Integer)
    url = Column(String)


class PersonalizedArtikel(Base):
    __tablename__ = 'personalized_artikel'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    artikel_id = Column(Integer, ForeignKey('artikel.id'))
    user = relationship(User)
    artikel = relationship(Artikel)
    liked = Column(Boolean, default = True)
    counter = Column(Integer, default = 0)
    #timespent = Zeit