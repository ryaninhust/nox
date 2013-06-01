# encoding:utf-8

from pymongo import *


class MongoUtil():
    tag_name_list = ['language', 'countries', 'tags', 'rate', 'people',
                     'editors', 'directors', 'actors', 'year', 'date', 'length', 'types']

    client = MongoClient('192.168.1.229', 27017)
    db = client.test
    collection = db.movies

    def get_types(self, tag_name):
        tags = self.collection.find({}, {tag_name: 1})
        tag_list = []
        for tag in tags:
            if(tag[tag_name] != None):
                tag_list.extend(tag[tag_name])
        print tag_list
        return tag_list

    def get_all_tags(self):
        for name in self.tag_name_list[:1]:
            self.get_types(name)


def main():
    test = MongoUtil()
    test.get_all_tags()

# main
if __name__ == "__main__":
    main()
