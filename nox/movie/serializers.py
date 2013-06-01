from rest_framework import serializers


class AnswerSerializer(serializers.Serializer):
    answer = serializers.CharField(max_length=5)


class QuestionSerializer(serializers.Serializer):
    question = serializers.CharField(max_length=250)
    movies_url = serializers.HyperlinkedIdentityField(view_name='question_movies')


class MovieSerializer(serializers.Serializer):
    id = serializers.CharField(max_length=15)
    name = serializers.CharField(max_length=250)
    directors = serializers.CharField(max_length=250)
    actors = serializers.CharField(max_length=250)
    types = serializers.CharField(max_length=250)
    countries = serializers.CharField(max_length=100)
    languages = serializers.CharField(max_length=100)
    year = serializers.CharField(max_length=100)
    length = serializers.CharField(max_length=100)
    rate = serializers.CharField(max_length=10)
    watcher = serializers.CharField(max_length=100)
    tags = serializers.CharField(max_length=250)
    cover_url = serializers.CharField(max_length=250)
