(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone', 'views/background', 'views/question', 'views/movie', 'views/result'], function(app, $, _, Backbone, BackgroundView, QuestionView, MovieView, ResultView) {
    var MainPage, _ref;

    return MainPage = (function(_super) {
      __extends(MainPage, _super);

      function MainPage() {
        this.renderResult = __bind(this.renderResult, this);
        this.renderMoive = __bind(this.renderMoive, this);
        this.renderQuestion = __bind(this.renderQuestion, this);
        this.render = __bind(this.render, this);
        this.restart = __bind(this.restart, this);        _ref = MainPage.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      MainPage.prototype.className = 'main-page';

      MainPage.prototype.templateHtml = $('#main-page-tmpl').html();

      MainPage.prototype.initialize = function() {
        app.on('getResult', this.renderResult);
        app.on('getMovies', this.renderMoive);
        return app.on('restart', this.restart);
      };

      MainPage.prototype.restart = function() {
        app.questionView.remove();
        app.movieView.remove();
        delete app.uid;
        delete app.questionView;
        delete app.movieView;
        return this.render();
      };

      MainPage.prototype.render = function() {
        (new BackgroundView()).render();
        this.$el.html(this.templateHtml);
        this.content = this.$el.find('.content');
        this.renderQuestion();
        this.renderMoive();
        return this;
      };

      MainPage.prototype.renderQuestion = function() {
        if (!app.questionView) {
          app.questionView = new QuestionView();
          return this.content.find('.question-wrapper').replaceWith(app.questionView.render().el);
        } else {
          return app.questionView.render();
        }
      };

      MainPage.prototype.renderMoive = function(moviesUrl) {
        if (!app.movieView) {
          app.movieView = new MovieView();
          this.content.find('.movie-panel').replaceWith(app.movieView.renderLoading().el);
        } else {
          app.movieView.renderLoading();
        }
        if (moviesUrl) {
          return app.movieView.setUrl(moviesUrl);
        }
      };

      MainPage.prototype.renderResult = function(option) {
        var resultView;

        if (option == null) {
          option = {};
        }
        resultView = new ResultView(option);
        return this.conent.append(resultView.render().el);
      };

      return MainPage;

    })(Backbone.View);
  });

}).call(this);
