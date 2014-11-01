from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import datetime
 
from sqlalchemy_declarative import Base, User, Artikel, PersonalizedArtikel, Schlagwort, PicUrl
 
engine = create_engine('sqlite:///database.db')
# Bind the engine to the metadata of the Base class so that the
# declaratives can be accessed through a DBSession instance
Base.metadata.bind = engine
 
DBSession = sessionmaker(bind=engine)
session = DBSession()
 
new_user = User(lastLogin = datetime.datetime.now())
session.add(new_user)
session.commit()

new_articel = Artikel(pageWikiId = "test1234", gattung = "Museum", offnungszeiten = "8.00", title = "ABC", url = "wikiUrl")
c1 = Schlagwort(text="aaa")
session.add(c1)

c2 = Schlagwort(text="bbb")
session.add(c2)

new_articel.schlagworter.append(c1)
new_articel.schlagworter.append(c2)

session.add(new_articel)
session.commit()
 
paritkel = PersonalizedArtikel(user=new_user, artikel=new_articel, liked = True, counter = 0)
session.add(paritkel)
session.commit()