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
      director: ''
      summary: '没有什么电影能满足你了!!（╯‵□′）╯︵'

    class Movies
      movieList: []
      movieIdTrash: []

      initialize: ->
        #this.on('delete', @delete)
        #this.on('update', @update)
        
      update: (newList)=>
        console.log(@filter(newList))
        @movieList = @filter(newList)

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
