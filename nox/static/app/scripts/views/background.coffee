define [
  'app'
  'jquery'
  'lodash'
  'backbone'
  'mods/blur'
  ], (app, $, _, Backbone, CanvasImage)->
    class BackgroundView extends Backbone.View
      initialize: ->
        @$el = $('.background-image')
        @el = @$el[0]
      imgList: [
        '/static/images/bg1.jpg'
        '/static/images/bg2.jpg'
        '/static/images/bg3.jpg'
        '/static/images/bg4.jpg'
      ]
      render: ->
        image = new Image()
        canvasElem = @$el.find('.bg-canvas')[0]
        image.onload = ->
          (new CanvasImage(canvasElem, this)).blur(4)
        image.src = @getImgUrl()

      getImgUrl: ->
        index = Math.random() * @imgList.length | 0
        @imgList[index]

        


