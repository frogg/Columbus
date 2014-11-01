from sqlalchemy_declarative import Base, User, Artikel, PersonalizedArtikel, Schlagwort, PicUrl
from sqlalchemy import create_engine
engine = create_engine('sqlite:///database.db')
Base.metadata.bind = engine
from sqlalchemy.orm import sessionmaker
DBSession = sessionmaker()
DBSession.bind = engine
session = DBSession()
# Make a query to find all Persons in the database
for user in session.query(User).all():
	print(user.id)
	print(user.lastLogin)
for artikel in session.query(Artikel).all():
	print(artikel.id)
	for word in artikel.schlagworter:
		print(word.text)
		print("Slide ID" + str(word.slide_id))

user = session.query(User).first()


# Find all Artikel whose user field is pointing to the person object
#session.query(Address).filter(Address.person == user).all()

# Retrieve one Address whose person field is point to the person object
personalarticel = session.query(PersonalizedArtikel).filter(PersonalizedArtikel.user == user).one()
print(personalarticel.artikel.schlagworter)
