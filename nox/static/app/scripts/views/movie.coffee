define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'mods/movies'
  ], (app, $, _, Backbone, Movies) ->

    class MovieView extends Backbone.View
      className: 'movie-panel'
      template: _.template($('#movie-panel-tmpl').html())
      events:
        'mouseenter .hd': 'openMoviePanel'
        'mouseleave .hd': 'closeMoviePanel'
        'click .like': 'like'
        'click .delete': 'delete'
      initialize: ()->
        @movies = new Movies()
        @movies.on('changed', @render)
        @

      setUrl: (url)=>
        @url = url
        @movies.fetch(url)

      render: ()=>
        movie = @movies.bestOne()
        @$el.html(@template(movie))
        @

      openMoviePanel: =>
        console.log('open')
        @

      closeMoviePanel: =>
        console.log('close')
        @

      like: (e)->
        target  = $(e.target)
        targetUrl = target.data('url')
        window.open(targetUrl)
        @

      delete: (e)->
        console.log('movieinfo:delete')
        target = $(e.target)
        infoElem = target.closest('.info')
        id = infoElem.data('id')
        app.movies.delete(id)
        @render()
        @
