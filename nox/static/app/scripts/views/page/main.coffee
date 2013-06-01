define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'views/question'
  'views/movie'
  'views/result'
  ], (app, $, _, Backbone,
    QuestionView, MovieView, ResultView) ->

    class MainPage extends Backbone.View
      className: 'main-page'
      templateHtml: $('#main-page-tmpl').html()
      initialize: ->
        app.on 'getResult', @renderResult
        app.on 'getMovies', @renderMoive

      render: =>
        @$el.html(@templateHtml)
        @content = @$el.find('.content')
        @renderQuestion()
        @

      renderQuestion: =>
        app.questionView?= new QuestionView()

        @content.find('.bd').empty()
          .append(app.questionView.render().el)

      renderMoive: (moviesUrl)=>
        app.movieView?= new MovieView()

        app.movieView.setUrl moviesUrl

        @content.find('.hd').empty()
          .append(app.movieView.render().el)

      renderResult: (option={})=>
        resultView = new ResultView(option)

        @conent
          .append(resultView.render().el)

