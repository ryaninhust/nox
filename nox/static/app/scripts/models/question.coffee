define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'mods/movies'  # TODO trash to fileter
], (app, $, _, Backbone, Movies)->
    class Question extends Backbone.Model
      defaults:
        # server
        question: '额，这并不是个问题, 这是个bug。。。'
        headUrl: ' '
        type: ' '
        movies: [
          {
            id: '2'
            name: 'aaa'
            cover_url: '/images/sample_cover.jpg'
            director: 'kk'
            summary: 'xxxxxx'
          }
          {
            id: '1'
            name: 'bb'
            cover_url: 'http://img3.douban.com/view/photo/photo/public/p1812483670.jpg'
            director: 'houkanshan'
            summary: 'xxxxxx'
          }
        ]
      toRenderJSON: =>
        question = @toJSON()
        app.movies.update(question.movies)
        question.movie = app.movies.bestOne()

        question
