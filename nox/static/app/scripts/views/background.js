(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone', 'mods/blur'], function(app, $, _, Backbone, CanvasImage) {
    var BackgroundView, _ref;

    return BackgroundView = (function(_super) {
      __extends(BackgroundView, _super);

      function BackgroundView() {
        _ref = BackgroundView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      BackgroundView.prototype.initialize = function() {
        this.$el = $('.background-image');
        return this.el = this.$el[0];
      };

      BackgroundView.prototype.imgList = ['/static/images/bg1.jpg', '/static/images/bg2.jpg', '/static/images/bg3.jpg', '/static/images/bg4.jpg'];

      BackgroundView.prototype.render = function() {
        var canvasElem, image;

        image = new Image();
        canvasElem = this.$el.find('.bg-canvas')[0];
        image.onload = function() {
          return (new CanvasImage(canvasElem, this)).blur(4);
        };
        return image.src = this.getImgUrl();
      };

      BackgroundView.prototype.getImgUrl = function() {
        var index;

        index = Math.random() * this.imgList.length | 0;
        return this.imgList[index];
      };

      return BackgroundView;

    })(Backbone.View);
  });

}).call(this);
