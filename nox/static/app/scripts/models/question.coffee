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
        movies_url: '/xxxxxxxx'
      toRenderJSON: =>
        question = @toJSON()

        question
