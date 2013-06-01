define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'mods/movies'
  ], (app, $, _, Backbone, Movies) ->
    loadData =
      id: ''
      name: ''
      cover_url: 'static/images/loading.png'
      summary: '在处理数据...'

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

      renderLoading: =>
        @$el.html(@template(loadData))
        @delegateEvents()
        @

      render: ()=>
        movie = @movies.bestOne()
        @$el.html(@template(movie))
        @delegateEvents()
        @

      openMoviePanel: =>
        @$el.find('.back-panel').show()
        app.trigger('panel:show')
        @

      closeMoviePanel: =>
        @$el.find('.back-panel').hide()
        app.trigger('panel:hide')
        @

      like: (e)->
        target  = $(e.target)
        targetUrl = target.data('url')
        window.open(targetUrl)
        @

      delete: (e)->
        target = $(e.target)
        infoElem = target.closest('.info')
        id = infoElem.data('id')
        @movies.delete(id)
        @

      restart: (e)->
        Backbone.Router.navgative('/')

