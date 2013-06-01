from django.db import models

# Create your models here.


class Movie(object):

    def __init__(self, name, director, actors,
                 types, country, language, date,
                 length, rate, watcher, tags):
        self.name = name
        self.director = director
        self.actors = actors
        self.types = types
        self.country = country
        self.language = language
        self.date = date
        self.length = length
        self.rate = rate
        self.watcher = watcher
        self.tags = tags


class Answer(object):

    def __init__(self, answer):
        self.answer = answer


class Question(object):

    def __init__(self, pk, question):
        self.pk = pk
        self.question = question
