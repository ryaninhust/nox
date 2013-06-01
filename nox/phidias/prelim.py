import pymongo

client = pymongo.MongoClient('192.168.1.229', 27017)
db = client.test


def fetch_all_movies():
    print [i for i in db.movies.find()]

if __name__ == "__main__":
    fetch_all_movies()
