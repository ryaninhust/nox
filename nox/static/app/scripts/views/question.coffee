define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'collections/questionSet'
  'models/question'
  'mixins/movie-info'
  ], (app, $, _, Backbone, QuestionSet, Question, movieInfo)->

    class QuestionView extends Backbone.View
      className: 'dialog-wrapper'
      template: _.template($('#question-dialog-tmpl').html())
      collection: new QuestionSet()
      currentQuestion: new Question()
      events:
        'click button[type=submit]': 'answerQuestion'
        'click .like': 'like'
        'click .delete': 'delete'
      initialize: ->
        @collection.on('add', @gotNewQuestion, this)
        # first question fire
        @getQuestion()
        
      render: ()->
        question = @currentQuestion.toRenderJSON()
        @$el.html(@template(question))
        @

      gotNewQuestion: (model, collection)->
        @currentQuestion = model
        @render()
        @

      getQuestion: (answer={})->
        $.post('/questions', answer)
          .done((r)=>
            @addQuestion(r)
          )
          .fail((r)=>
            # 测试数据
            @trick?= '是么？那'
            @trick += '那'
            r =
              type: 'question'
              question: @trick + '你吃过测试么？'
            @addQuestion(r)
          )

      answerQuestion: (e)->
        e = $(e.target)
        answer =
          value: e.val()
        @getQuestion(answer)
        @

      addQuestion: (gotQuestion)->
        queston = new Question(gotQuestion)
        @collection.add(queston)
        @

    _.extend QuestionView.prototype, movieInfo

    QuestionView
