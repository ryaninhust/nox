from rest_framework import serializers


class AnswerSerializer(serializers.Serializer):
    answer = serializers.CharField(max_length=5)



class QuestionSerializer(serializers.Serializer):
    question = serializers.CharField(max_length=250)
    movies = serializers.HyperlinkedIdentityField(view_name='question_movies')


class MovieSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=250)
    director = serializers.CharField(max_length=250)
    actors = serializers.CharField(max_length=250)
    types = serializers.CharField(max_length=250)
    country = serializers.CharField(max_length=100)
    language = serializers.CharField(max_length=100)
    date = serializers.CharField(max_length=100)
    length = serializers.CharField(max_length=100)
    rate = serializers.CharField(max_length=10)
    watcher = serializers.CharField(max_length=100)
    tags = serializers.CharField(max_length=250)
