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
    lastLogin = Column(DateTime(timezone=True),
                       primary_key=False,
                       nullable=False,
                       default=datetime.datetime.now())


class Artikel(Base):
    __tablename__ = 'artikel'
    pageWikiId = Column(Integer, primary_key=True)
    latitude = Column(Float)
    longitude = Column(Float)
    gattung = Column(String(50))
    schlagworter = relationship('Schlagwort', backref='artikel',
                                collection_class=ordering_list('position'),
                                order_by='Schlagwort.position')
    picUrl = Column(String(300))
    address = Column(Text)
    offnungszeiten = Column(Text)
    url = Column(String(300))
    title = Column(String(50))
    summary = Column(Text)


class Schlagwort(Base):
    __tablename__ = 'schlagwort'
    id = Column(Integer, primary_key=True)
    slide_id = Column(Integer, ForeignKey('artikel.pageWikiId'))
    position = Column(Integer)
    text = Column(String(50))

    def __repr__(self):
        return self.text


class PersonalizedArtikel(Base):
    __tablename__ = 'personalized_artikel'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    artikel_id = Column(Integer, ForeignKey('artikel.pageWikiId'))
    user = relationship(User)
    artikel = relationship(Artikel)
    liked = Column(Boolean, default=True)
    counter = Column(Integer, default=0)
    #timespent = Zeit


class Rating(Base):
    __tablename__ = 'rating'
    id = Column(Integer, primary_key=True)
    user_id = Column(Integer, ForeignKey('user.id'))
    categoryName = Column(String(50))
    likes = Column(Integer, default = 0)
    dislikes = Column(Integer, default = 0)
    totalLikeTime = Column(Integer, default = 0)
