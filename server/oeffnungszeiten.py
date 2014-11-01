import math
import requests
import json

def calculateLikes(likes, dislikes, totalLikeTime):

    likeMultiplier = 4
    if isinstance(likes, int) and isinstance(dislikes, int) and isinstance(totalLikeTime, int):
        totalVotes = likes + dislikes
        averageTime = totalLikeTime / totalVotes
        timeLikes = totalLikeTime / (averageTime*likeMultiplier)
        print (timeLikes)
        totalLikes = (likes + timeLikes - dislikes)*20
        if totalLikes > 1000:
        	totalLikes = 1000
        return totalLikes
    else:
        return None

def getPlacesAtLocation(lattitude, longitude, radius, types):
    try:
        types = "|".join(types)
        result = {}
        shittyHardcodedBlacklist = ["establishment"]
        shittyHardcodedTierlist1 = [""]
        shittyHardcodedTierlist2 = [""]
        shittyHardcodedTierlist3 = [""]
        try:
            r = requests.get('https://maps.googleapis.com/maps/api/place/radarsearch/json?location='+str(lattitude)+','+str(longitude)+'&radius='+str(radius)+'&types='+types+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            #r = requests.get('https://maps.googleapis.com/maps/api/place/textsearch/json?query=bw+bank+stuttgart&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            placeID = r['results'][0]['place_id']
            r = requests.get('https://maps.googleapis.com/maps/api/place/details/json?placeid='+placeID+'&key=AIzaSyDW9MwGaplwwDRo9Fn2uZweW8LN1tuomBQ').json()
            
            try:
                result['address'] = r['result']['formatted_address']
            except:
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
                print ("Error found:")
                print (e)
                result['open_now'] = None
                result['opening_times'] = None
        except IndexError as e:
            print (e)
            result['types'] = None
            result['open_now'] = None
            result['opening_times'] = None
        return result
    except ConnectionError as e:
        return None


print(getPlacesAtLocation(48.7825, 9.17015, 200, ['museum']))