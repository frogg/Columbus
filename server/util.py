import requests
import hashlib
from sqlalchemy_declarative import Rating
from sqlalchemy.orm.exc import NoResultFound

def getPlacesAtLocation(lattitude, longitude, radius):
    try:
        types = [
            'museum',
            'aquarium',
            'art_gallery',
            'book_store',
            'cemetery',
            'church'
            'city_hall',
            'hindu_temple',
            'library',
            'museum',
            'place_of_worship',
            'stadium',
            'university',
            'zoo']
        types = "|".join(types)
        result = {}
        shittyHardcodedBlacklist = ["establishment"]
        shittyHardcodedTierlist1 = ["museum", "library", "church", "bibliothek", "university", "universität"]
        supershittygermanpythondictionary = {"bücherei":"library","kirche":"church","universität":"university"}
        shittyHardcodedTierlist2 = [""]
        shittyHardcodedTierlist3 = [""]
        try:
            r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            #r = requests.get('https://maps.googleapis.com/maps/api/place/textsearch/json?query=bw+bank+stuttgart&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            placeID = r['results'][0]['place_id']
            r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            
            try:
                result['address'] = r['result']['formatted_address']
            except KeyError:
                result['address'] = None

            try:
                typeReturn2 = None
                typeReturn3 = None
                for x in r['result']['types']:
                    if x not in shittyHardcodedBlacklist:
                        if x in shittyHardcodedTierlist1:
                            result['types'] = x
                            break
                        if x in shittyHardcodedTierlist2:
                            if typeReturn2 == None:
                                typeReturn2 = x
                        if x in shittyHardcodedTierlist3:
                            if typeReturn3 == None:
                                typeReturn3 = x
                    if typeReturn2 == None:
                        if typeReturn3 == None:
                            result['types'] = None
                        else:
                            result['types'] = typeReturn3
                    else: 
                        result['types'] = typeReturn2



            except KeyError:
                result['types'] = None

            if result['types'] == None:
                for x in shittyHardcodedTierlist1:
                    if x in r['result']['name']:
                        result['types'] = x

            if result['types'] in supershittygermanpythondictionary:
                result['types'] = supershittygermanpythondictionary[result['types']]

            try:
                if r['result']['opening_hours']['open_now']:
                    result['open_now'] = r['result']['opening_hours']['open_now']
                else:
                    result['open_now'] = False

                result['opening_times'] = {'mon': [None, None, None, None],
                                           'tue': [None, None, None, None],
                                           'wed': [None, None, None, None],
                                           'thu': [None, None, None, None],
                                           'fri': [None, None, None, None],
                                           'sat': [None, None, None, None],
                                           'sun': [None, None, None, None]}
                for row in r['result']['opening_hours']['periods']:
                    if row['open']['day'] == 0:
                        day = 'sun'
                    elif row['open']['day'] == 1:
                        day = 'mon'
                    elif row['open']['day'] == 2:
                        day = 'tue'
                    elif row['open']['day'] == 3:
                        day = 'wed'
                    elif row['open']['day'] == 4:
                        day = 'thu'
                    elif row['open']['day'] == 5:
                        day = 'fri'
                    elif row['open']['day'] == 6:
                        day = 'sat'

                    if result['opening_times'][day][0] != None:
                        tempclosing = result['opening_times'][day][3]
                        tempopening = result['opening_times'][day][0]
                        result['opening_times'][day] = [tempopening, tempclosing, row["open"]["time"], row["close"]["time"]]
                    else:
                        result['opening_times'][day] = [row["open"]["time"], None, None, row["close"]["time"]]
            except KeyError as e:
                #print ("Error found:")
                #print (e)
                result['open_now'] = None
                result['opening_times'] = None
        except IndexError as e:
            #print (e)
            result['types'] = None
            result['open_now'] = None
            result['opening_times'] = None
        return result
    except ConnectionError as e:
        return None



def geosearch(latitude, longitude, gtype,radius): 
    return apicall('en', 'query', 'json', "&type={0}&gsradius={3}&gscoord={1}|{2}&gslimit=20&gsprop=type&list=geosearch".format(gtype, latitude,longitude,radius)).get('query').get('geosearch')


def getImage(page_IDs):
    page_IDs = "|".join(page_IDs)
    response= apicall('en', 'query', 'json', "&prop=pageimages&inprop=url&pageids={0}&pithumbsize=600".format(page_IDs)).get('query')
    try:
        for page in response.get('pages'):
            
            image = response.get('pages').get(page).get('thumbnail').get('source')
            if "logo" in image or ".svg" in image or "Logo" in image:
                imagename = response.get('pages').get(page).get('pageimage').replace('_', ' ')
                for name in getListofImagesForPage(page_IDs):
                    if imagename in name.get('title'):
                        continue
                    image = calculateWikimediaFilePath(name.get('title'))
        if ".svg" in image:
            return None
        return image
    except AttributeError:
        return None


def calculateWikimediaFilePath(filename):
    url = "http://upload.wikimedia.org/wikipedia/commons/"
    filename = filename.replace(" ","_").split(':')[1]
    m = hashlib.md5()
    m.update(filename.encode('utf-8'))
    md5sum = m.hexdigest()
    return url+md5sum[:1]+"/"+md5sum[:2]+"/"+filename


def getListofImagesForPage(page_IDs):
    image_names = []
    response= apicall('en', 'query', 'json', "&prop=imageinfo|images&inprop=url&pageids={0}".format(page_IDs)).get('query')
    for page in response.get('pages'):
        for image in response.get('pages').get(page).get('images'):
            image_names.append(image)
    return image_names

def apicall(language, action, response_format, specialValues):
    url = "https://{0}.wikipedia.org/w/api.php?action={1}&format={2}{3}".format(language,action,response_format,specialValues)
    print(url)
    r = requests.get(url)
    r = r.json()
    return r


def getSchlagworter(title, url):
    r = requests.get('http://access.alchemyapi.com/calls/url/URLGetRankedKeywords?apikey=42918a4b1646af1e6e18c3048afced054c452dd4&url={0}&outputMode=json&maxRetrieve=7'.format(url))
    if not r.status_code == requests.codes.ok:
        return []
    z = r.json()
    count = 0
    keywords= []
    for word in z['keywords']:
        if count < 5:
            if title in word['text']:
                count+= 1
            else:
                keywords.append(word['text'])
        else:
            keywords.append(word['text'])
    return keywords[:5]


def calculateLikes(category, userID, session, distance):
    try:
        if category:
            ratingCategory = session.query(Rating).filter(
                Rating.user_id == userID
                ).filter(
                category == Rating.categoryName
                ).one()
        else:
            ratingCategory = session.query(Rating).filter(
                Rating.user_id == userID
                ).filter(
                Rating.categoryName == None
                ).one()
        likes = ratingCategory.likes
        dislikes = ratingCategory.dislikes
        totalLikeTime = ratingCategory.totalLikeTime
        average_time = totalLikeTime/(likes+dislikes)/500

        totalLikes = ((likes-dislikes)+average_time)*1000-distance

        return totalLikes
    except NoResultFound:
        return 1
