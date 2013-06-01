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
        'mouseenter': 'openMoviePanel'
        'mouseleave': 'closeMoviePanel'
        'click .like': 'like'
        'click .delete': 'delete'
        'click .restart': 'restart'

      initialize: ()->
        @movies = new Movies()
        @movies.on('changed', @render)
        #@openMoviePanel = _.debounce @openMoviePanel
        @

      setUrl: (url)=>
        @url = url
        @movies.fetch(url)

      render: ()=>
        movie = @movies.bestOne()
        @$el.html(@template(movie))
        @delegateEvents()
        @

      openMoviePanel: =>
        @$el.find('.back-panel').show()
        app.trigger('panel:show')
        console.log('open')
        @

      closeMoviePanel: =>
        @$el.find('.back-panel').hide()
        app.trigger('panel:hide')
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
        @movies.delete(id)
        @

      restart: (e)->
        Backbone.router.navgative('/')
