# encoding:utf-8

from pymongo import *
import redis
import json


def flatten(iterable):
    """Recursively iterate lists and tuples.
    """
    for elm in iterable:
        if isinstance(elm, (list, tuple)):
            for relm in flatten(elm):
                yield relm
        else:
            yield elm


class MongoUtil():
    tag_name_list = ['language', 'countries', 'tags', 'rate', 'people',
                     'editors', 'directors', 'actors', 'year', 'date', 'length', 'types']

    client = MongoClient('192.168.1.229', 27017)
    db = client.test
    collection = db.movies

    def get_types(self, tag_name):
        tags = collection.find({}, {tag_name: 1})
        tag_list = []
        for tag in tags:
            tag_list.append(tag.get(tag_name))
        return list(flatten(tag_list))


class RedisUtil():
    r = redis.StrictRedis(host='localhost')
    tag_name_list = ['language', 'countries', 'tags', 'rate', 'people',
                     'editors', 'directors', 'actors', 'year', 'date', 'length', 'types']

    def get_types(self, unique_id, tag_name):
        data = json.loads(self.r.get(unique_id))
        feature_list = []
        for item in data:
            feature_list.append(item.get(tag_name))
        return list(flatten(feature_list))

    def get_split_feature(self, unique_id):
        return self.r.members(unique_id+'feature')

    def get_data(self, unique_id):
        return json.loads(self.r.get(unique_id))

    def set_data(self, unique_id, data):
        self.r.set(unique_id, json.dumps(data))

    def set_split_feature(self, unique_id, points):
        self.r.sadd(unique_id+'feature', points)

    def get_split_feature(self, unique_id):
        self.r.get(unique_id+'feature')

    def get_filter_points(self, unique_id):
        return self.r.smembers(unique_id+'filter')

    def append_filter_points(self, unique_id, points):
        self.r.sadd(unique_id+'filter', points)


def main():
    test = MongoUtil()
    print test.get_types('types')

# main
if __name__ == "__main__":
    main()
