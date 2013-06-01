# -*- coding: utf-8 -*-
import os
import json
import urllib2
import mimetypes
import re
from django.shortcuts import render
from django.http import HttpResponse
from django.core.servers.basehttp import FileWrapper
from django.conf import settings

from rest_framework import viewsets
from rest_framework import generics
from rest_framework import mixins
from rest_framework.response import Response

from movie.models import Movie, Question, Answer
from movie.serializers import AnswerSerializer, QuestionSerializer, MovieSerializer



def index_view(request):
    return render(request, "index.html")

def photo_view(request, pid):
    cover_folder = os.path.abspath(os.path.join(settings.COVER_PATH, os.pardir,os.pardir, "cover/"))
    if not os.path.exists(cover_folder):
        os.mkdir(cover_folder)

    filename = pid + ".jpg"
    dest_addr = os.path.abspath(os.path.join(settings.COVER_PATH, os.pardir,os.pardir, "cover/", filename))
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
            photo_url = "http://img3.douban.com/lpic/" + img_name.split("/")[-1]
        except:
            get_img = re.compile(r"\w(\d+)\.jpg")
            if get_img.findall(img_name):
                img_id = get_img.findall(img_name)[0]
            else:
                img_id = "1291545"
            photo_url = "http://img3.douban.com/view/photo/photo/public/p"+ img_id + ".jpg"

        print photo_url
        try:
            stream = urllib2.urlopen(photo_url)
        except:
            try:
                another_url =  "http://img3.douban.com/lpic/s" + pid + ".jpg"
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
        movies = []

        movie = Movie(id="3642843", name="a", directors="a", actors="a",
                types="a", countries="a", language='中文',
                year='a', length='110', rate='2.4',
                people='200', tags="a",editors="editors",cover_url="/photos/3642843")
        bmovie = Movie(id="11529526", name="b", directors="b", actors="b",
                types="b", countries="b", language="英语",
                year='b', length='110', rate='3.5', editors="editorsb",
                people='200', tags="b", cover_url="/photos/11529526")
        movies.append(movie)
        movies.append(bmovie)
        movie_json = MovieSerializer(movies)
        return Response(movie_json.data)


class QuestionViewSet(viewsets.ViewSetMixin,
        generics.GenericAPIView):

    serializer_class = QuestionSerializer
    def answer_question(self, request, *args, **kwargs):
        answer = Answer(request.DATA)
        question = Question(pk=1, question="asda")
        question_json = QuestionSerializer(question)
        return Response(question_json.data)

    def ask_question(self, request, *args, **kwargs):
        _view = MovieViewSet.as_view({'get': 'get_movies'})
        return _view(request, args, kwargs)


