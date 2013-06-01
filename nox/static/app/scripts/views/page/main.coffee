define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'views/question'
  'views/result'
  ], (app, $, _, Backbone, QuestionView, ResultView) ->
    class MainPage extends Backbone.View
      className: 'main-page'
      templateHtml: $('#main-page-tmpl').html()
      initialize: ->
        app.on 'getResult', @renderResult

      render: =>
        @$el.html(@templateHtml)
        @content = @$el.find('.content')
        @renderQuestion()
        @

      renderQuestion: =>
        questionView = new QuestionView()

        @content.empty()
          .append(questionView.render().el)

      renderResult: (option={})=>
        resultView = new ResultView(option)

        @conent
          .append(resultView.render().el)

