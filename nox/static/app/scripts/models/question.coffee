define [
  'jquery'
  'lodash'
  'backbone'
], ($, _, backbone)->
    class Question extends Backbone.Model
      defaults:
        # server
        question: '额，这并不是个问题, 这是个bug。。。'
        headUrl: ' '
        type: ' '

    Question
