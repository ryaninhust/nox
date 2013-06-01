# -*- coding: utf-8 -*-
from django.db import models

# Create your models here.


class Movie(object):

    def __init__(self,id, name, directors, actors,
                 types, countries, editors, language, year,
                 length, rate, people, tags, cover_url):
        self.id = id
        self.name = name
        self.directors = directors
        self.actors = actors
        self.editors = editors
        self.types = types
        self.countries = countries
        self.language = language
        self.year = year
        self.length = length
        self.rate = rate
        self.people = people
        self.tags = tags
        self.cover_url = cover_url

class Answer(object):

    def __init__(self, answer):
        self.answer = answer


class Question(object):

    def __init__(self, pk, question, uid):
        self.pk = pk
        self.question = question
        self.uid = uid
