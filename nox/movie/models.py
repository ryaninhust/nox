from django.db import models

# Create your models here.


class Movie(object):

    def __init__(self, name, directors, actors,
                 types, countries, languages, year,
                 length, rate, watcher, tags):
        self.name = name
        self.directors = directors
        self.actors = actors
        self.types = types
        self.countries = countries
        self.languages = languages
        self.year = year
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
