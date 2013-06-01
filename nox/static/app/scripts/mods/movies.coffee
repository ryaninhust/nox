define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  ], (app, $, _, Backbone) ->
    defaultMoive =
      noAction: true
      cover_url: '/static/images/sample_cover.jpg'
      id: '0'
      name: ''
      directors: ''
      actors: ''
      editors: ''
      tags: ''
      rate: ''
      people: ''
      language: ''
      countries: ''
      length: ''
      types: ''
      year: ''
      summary: '没有电影了!!（╯‵□′）╯︵'

    class Movies
      constructor: ->
        console.log('new movie')
        @movieIdTrash = []
        @movieList = []

      fetch: (url)=>
        console.log(url)
        $.get(url)
          .done (r)=>
            @update(r)
              
      update: (newList)=>
        console.log(@filter(newList))
        @movieList = @filter(newList)
        @trigger('changed')

      delete: (movieId)=>
        console.log('delete', movieId)
        @movieIdTrash.push movieId+''
        @update @movieList
        console.log('after delete', @movieList)

      filter: (list)=>
        _.filter list, (e)=>
          e.id not in @movieIdTrash

      bestOne: ->
        if @movieList.length
          @movieList[0]
        else
          defaultMoive

    _.extend Movies.prototype, Backbone.Events

    Movies
