def calculateLikes(likes, dislikes, totalLikeTime):

    if isinstance(likes, int) and isinstance(dislikes, int) and isinstance(totalLikeTime, int):
        average_time = totalLikeTime/(likes+dislikes)/500

        totalLikes = (likes-dislikes)+average_time

        return totalLikes
    else:
        return None
