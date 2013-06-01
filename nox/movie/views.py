from rest_framework import viewsets
from rest_framework import generics
from rest_framework import mixins
from rest_framework.response import Response

from movie.models import Movie, Question, Answer
from movie.serializers import AnswerSerializer, QuestionSerializer, MovieSerializer


class MovieViewSet(viewsets.ViewSetMixin,
                   generics.GenericAPIView,
                   mixins.SubModelMixin):

    serializer_class = MovieSerializer
    def get_movies(self, request, *args, **kwargs):
        movie = Movie(name="a", director='a', actors='a',
                      types='a', country='a', language='a',
                      date='a', length='a', rate='a',
                      watcher='a', tags='a')
        movie_json = MovieSerializer(movie)
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
