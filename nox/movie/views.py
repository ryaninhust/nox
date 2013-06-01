# -*- coding: utf-8 -*-
import os
import json
import urllib2
import mimetypes
import re
import redis

from django.shortcuts import render
from django.http import HttpResponse
from django.core.servers.basehttp import FileWrapper
from django.conf import settings
from werkzeug import security

from rest_framework import viewsets
from rest_framework import generics
from rest_framework import mixins
from rest_framework.response import Response

from movie.models import Movie, Question, Answer
from movie.serializers import AnswerSerializer, QuestionSerializer, MovieSerializer
from phidias.phidias import pick_point, pick_movies, climax
from phidias.prelim import flatten


r = redis.StrictRedis(host='localhost')


def ask_problem(feature, value):
    if feature == "language":
        return u"这部电影是" + value + u"电影吗？"
    elif feature == "countries":
        return u"这部电影是来自" + value + u"的吗？"
    elif feature == "tags":
        return u"这部电影和" + value + u"有关的吗？"
    elif feature == "rate" and int(value) > 8:
        return u"这部电影是否广受赞誉？"
    elif feature == "rate" and int(value) > 9:
        return u"这部电影是否非常经典？"
    elif feature == "people" and int(value) < 100:
        return u"这部电影是否非常冷门"
    elif feature == "people" and int(value) > 30000:
        return u"这部电影是否非常热门"
    elif feature == "editors":
        return u"这部电影是不是" + value + u"作为编剧"
    elif feature == "directors":
        return u"这部电影难道是由" + value + u"拍摄的"
    elif feature == "actors":
        return u"这部电影有没有" + value + u"参与出演"
    elif feature == "date":
        return u"这是一部" + value + u"左右拍摄出的电影吗"
    elif feature == "length" and int(value) > 150:
        return u"这是一部时间很长的电影？"
    elif feature == "length" and int(value) < 45:
        return u"这是个短片？"
    elif feature == "types":
        return u"这是个" + value + u"片？"
    else:
        return u"我不知道该问什么了。。"


def index_view(request):
    return render(request, "index.html")


def photo_view(request, pid):
    cover_folder = os.path.abspath(os.path.join(
        settings.COVER_PATH, os.pardir, os.pardir, "cover/"))
    if not os.path.exists(cover_folder):
        os.mkdir(cover_folder)

    filename = pid + ".jpg"
    dest_addr = os.path.abspath(os.path.join(
        settings.COVER_PATH, os.pardir, os.pardir, "cover/", filename))
    if os.path.exists(dest_addr):
        file_content = open(dest_addr).read()
    else:
        subject = "http://movie.douban.com/subject/" + pid + "/"
        cv = re.compile(r"")
        page = urllib2.urlopen(subject).read()
        getLink = re.compile(r"img.*?(?<=src=\")(.*?)(?=\"\s*title=\"点击)")
        getLink2 = re.compile(r"a.*?(?<=href=\")(.*?)(?=\"\s*title=\"点击)")
        img_results = getLink.findall(page)
        if img_results:
            img_name = img_results[0]
        else:
            img_results = getLink2.findall(page)
            if img_results:
                img_name = img_results[0]
            else:
                img_name = "s1291545.jpg"

        try:
            img_name.index("pic")
            photo_url = "http://img3.douban.com/lpic/" + \
                img_name.split("/")[-1]
        except:
            get_img = re.compile(r"\w(\d+)\.jpg")
            if get_img.findall(img_name):
                img_id = get_img.findall(img_name)[0]
            else:
                img_id = "1291545"
            photo_url = "http://img3.douban.com/view/photo/photo/public/p" + \
                img_id + ".jpg"

        print photo_url
        try:
            stream = urllib2.urlopen(photo_url)
        except:
            try:
                another_url = "http://img3.douban.com/lpic/s" + pid + ".jpg"
                stream = urllib2.urlopen(another_url)
            except:
                pass
        file_content = stream.read()
        new_file = open(dest_addr, "wb")
        new_file.write(file_content)
        new_file.close()
    response = HttpResponse(file_content, mimetype='content_type')
    return response


class MovieViewSet(viewsets.ViewSetMixin,
                   generics.GenericAPIView,
                   mixins.SubModelMixin):
    serializer_class = MovieSerializer

    def get_movies(self, request, *args, **kwargs):
        token = request.GET["uid"]
        new_movies = []
        movies = pick_movies(token)
        for movie in movies:
            if "summary" in movie:
                summary = movie["summary"]
            else:
                summary = ""
            movie = Movie(
                id=movie["movie_id"],
                name=movie["name"],
                directors=",".join(flatten(movie[
                                   "directors"])) if movie["directors"] else "",
                actors=",".join(flatten(movie[
                                "actors"])) if movie["actors"] else "",
                language=",".join(flatten(movie[
                                  "language"])) if movie["actors"] else "",
                types=",".join(flatten(movie[
                               "types"])) if movie["types"] else "",
                countries=",".join(flatten(movie[
                                   "countries"])) if movie["countries"] else "",
                year=movie["year"] if movie["year"] else "",
                length=movie["length"] if movie["length"] else "",
                rate=movie["rate"],
                editors=",".join(flatten(movie[
                                 "editors"])) if movie["editors"] else "",
                people=movie["people"],
                tags=",".join(flatten(movie[
                              "tags"])) if movie["people"] else "",
                cover_url="/photos/" + movie["movie_id"],
                summary=summary,
            )
            print movie
            new_movies.append(movie)
        movie_json = MovieSerializer(new_movies)
        return Response(movie_json.data)


class QuestionViewSet(viewsets.ViewSetMixin,
                      generics.GenericAPIView):
    serializer_class = AnswerSerializer

    def answer_question(self, request, *args, **kwargs):
        try:
            token = request.GET["uid"]
            if token == "":
                token = create_token(8)
        except:
            token = create_token(8)
        answer = Answer(request.DATA).answer
        question_content = u"一个问题"
        if answer:
            answer = int(answer["answer"])
            climax(token, int(answer))
            results = pick_point(token)
            feature = results[0]
            content = results[1].decode("utf-8")
            question_content = ask_problem(feature, content)
        else:
            return Response({"error": "fail"})
        question = Question(pk=1, question=question_content, uid=token)
        question_json = QuestionSerializer(question)
        return Response(question_json.data)

    def ask_question(self, request, *args, **kwargs):
        _view = MovieViewSet.as_view({'get': 'get_movies'})
        return _view(request, args, kwargs)


def create_token(length):
    return security.gen_salt(length)
