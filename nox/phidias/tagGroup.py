# encoding:utf-8

from pymongo import *

class MongoUtil():
    tagNameList = ['language', 'countries', 'tags', 'rate', 'people', 'editors', 'directors', 'actors', 'year', 'date', 'length', 'types']

    client = MongoClient('192.168.1.229', 27017)
    db = client.test
    collection = db.movies

    def getTypes(self, tagName):
        tags = self.collection.find({}, {tagName:1})
        tagList = []
        for tag in tags:
            if(tag[tagName] != None):
                tagList.extend(tag[tagName])
        print tagList
        return tagList

    def getAllTags(self):
        for name in tagNameList:
            getTypes(self, name)

    

def main():
    test = MongoUtil()
    test.getAllTags()
    
# main
if __name__ == "__main__":
    main()
