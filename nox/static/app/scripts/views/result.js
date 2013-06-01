(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone'], function(app, $, _, Backbone) {
    var ResultView, _ref;

    return ResultView = (function(_super) {
      __extends(ResultView, _super);

      function ResultView() {
        this.restart = __bind(this.restart, this);
        this.render = __bind(this.render, this);        _ref = ResultView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      ResultView.prototype.className = 'dialog-wrapper';

      ResultView.prototype.template = _.template($('#result-dialog-tmpl').html());

      ResultView.prototype.events = {
        'click .again': 'restart'
      };

      ResultView.prototype.initialize = function(option) {
        return this.render(option.data);
      };

      ResultView.prototype.render = function(data) {
        this.$el.html(this.template(data));
        return this;
      };

      ResultView.prototype.restart = function() {
        app.navigate('/');
        return this;
      };

      return ResultView;

    })(Backbone.View);
  });

}).call(this);
