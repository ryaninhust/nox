(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone', 'mods/movies'], function(app, $, _, Backbone, Movies) {
    var MovieView, loadData, _ref;

    loadData = {
      id: '',
      name: '',
      cover_url: 'static/images/loading.png',
      summary: '在处理数据...'
    };
    return MovieView = (function(_super) {
      __extends(MovieView, _super);

      function MovieView() {
        this.closeMoviePanel = __bind(this.closeMoviePanel, this);
        this.openMoviePanel = __bind(this.openMoviePanel, this);
        this.render = __bind(this.render, this);
        this.renderLoading = __bind(this.renderLoading, this);
        this.hackOverflow = __bind(this.hackOverflow, this);
        this.rolling = __bind(this.rolling, this);
        this.setUrl = __bind(this.setUrl, this);        _ref = MovieView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      MovieView.prototype.className = 'movie-panel';

      MovieView.prototype.template = _.template($('#movie-panel-tmpl').html());

      MovieView.prototype.events = {
        'mouseenter': 'openMoviePanel',
        'mouseleave': 'closeMoviePanel',
        'click .like': 'like',
        'click .delete': 'delete',
        'click .restart': 'restart'
      };

      MovieView.prototype.initialize = function() {
        this.movies = new Movies();
        this.movies.on('changed', this.render);
        app.on('loading', this.rolling);
        return this;
      };

      MovieView.prototype.setUrl = function(url) {
        this.url = url;
        this.rolling();
        return this.movies.fetch(url);
      };

      MovieView.prototype.rolling = function() {
        return this.$el.find('.cover').addClass('roll');
      };

      MovieView.prototype.hackOverflow = function() {
        return this.$el.animate({
          'margin-top': '-=1px'
        }, 'fast').animate({
          'margin-top': '+=1px'
        }, 'fast');
      };

      MovieView.prototype.renderLoading = function() {
        this.$el.html(this.template(loadData));
        this.rolling();
        this.hackOverflow();
        this.delegateEvents();
        return this;
      };

      MovieView.prototype.render = function() {
        var movie;

        console.log('change');
        movie = this.movies.bestOne();
        this.$el.html(this.template(movie));
        this.hackOverflow();
        this.delegateEvents();
        return this;
      };

      MovieView.prototype.openMoviePanel = function() {
        this.$el.find('.back-panel').show().addClass('slide-in');
        app.trigger('panel:show');
        return this;
      };

      MovieView.prototype.closeMoviePanel = function() {
        this.$el.find('.back-panel').hide().removeClass('slide-in');
        app.trigger('panel:hide');
        return this;
      };

      MovieView.prototype.like = function(e) {
        var target, targetUrl;

        target = $(e.target);
        targetUrl = target.data('url');
        window.open(targetUrl);
        return this;
      };

      MovieView.prototype["delete"] = function(e) {
        var id, infoElem, target;

        target = $(e.target);
        infoElem = target.closest('.info');
        id = infoElem.data('id');
        this.movies["delete"](id);
        return this;
      };

      MovieView.prototype.restart = function(e) {
        return app.trigger('restart');
      };

      return MovieView;

    })(Backbone.View);
  });

}).call(this);
