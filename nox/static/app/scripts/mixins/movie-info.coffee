define [
  'app'
  'jquery'
  'lodash'
  ], (app, $, _) ->
    MovieInfo =
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
