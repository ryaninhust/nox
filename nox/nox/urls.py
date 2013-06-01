from django.conf import settings
from django.conf.urls import patterns, include, url
from movie import views

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()
question_view = views.QuestionViewSet.as_view({'post': 'answer_question'})
question_movies = views.QuestionViewSet.as_view({'get': 'ask_question'})
urlpatterns = patterns('',
    url(r'^$', views.index_view, name='index_view'),
    url(r'^questions/$', question_view, name='question_view'),
    url(r'^questions/(?P<pk>[0-9]+)/movies',
         question_movies, name='question_movies')

    # Examples:
    # url(r'^$', 'nox.views.home', name='home'),
    # url(r'^nox/', include('nox.foo.urls')),

    # Uncomment the admin/doc line below to enable admin documentation:
    # url(r'^admin/doc/',
    # include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    # url(r'^admin/', include(admin.site.urls)),
)
