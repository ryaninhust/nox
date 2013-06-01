define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'views/question'
  'views/result'
  'mods/movies'
  ], (app, $, _, Backbone,
    QuestionView, ResultView, Movies) ->
    class MainPage extends Backbone.View
      className: 'main-page'
      templateHtml: $('#main-page-tmpl').html()
      initialize: ->
        app.on 'getResult', @renderResult
        app.movies = new Movies

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

