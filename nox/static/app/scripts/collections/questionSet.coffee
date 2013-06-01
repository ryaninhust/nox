define [
  'jquery'
  'lodash'
  'backbone'
  'models/question'
  ], ($, _, backbone, Question) ->
    class QuestionSet extends Backbone.Collection
      model: Question
      initialize: ->
        @

    QuestionSet
