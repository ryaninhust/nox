define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  ], (app, $, _, Backbone)->
    class ResultView extends Backbone.View
      className: 'dialog-wrapper'
      template: _.template($('#result-dialog-tmpl').html())
      events:
        'click .again': 'restart'
      initialize: (option)->
        @render(option.data)

      render: (data)=>
        @$el.html(@template(data))
        @
      
      restart: =>
        app.navigate('/')
        @
