define [
  'jquery'
  'lodash'
  'backbone'
  #'mod/trash'  # TODO trash to fileter
], ($, _, backbone)->
    class Question extends Backbone.Model
      defaults:
        # server
        question: '额，这并不是个问题, 这是个bug。。。'
        headUrl: ' '
        type: ' '
        movies: [
          {
            name: 'aaa'
            cover_url: 'http://img3.douban.com/view/photo/photo/public/p1812483670.jpg'
            director: 'kk'
            summary: 'xxxxxx'
          }
          {
            name: 'bb'
            cover_url: 'http://img3.douban.com/view/photo/photo/public/p1812483670.jpg'
            director: 'houkanshan'
            summary: 'xxxxxx'
          }
        ]
      toRenderJSON: =>
        question = @toJSON()
        movie = @selectmovie(question.movies)
        question.movie = movie
        question

      selectmovie: (movies)=>
        #TODO fileter
        movies[0]

    Question
