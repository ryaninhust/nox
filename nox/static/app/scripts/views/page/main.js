(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone', 'views/question', 'views/result', 'mods/movies'], function(app, $, _, Backbone, QuestionView, ResultView, Movies) {
    var MainPage, _ref;

    return MainPage = (function(_super) {
      __extends(MainPage, _super);

      function MainPage() {
        this.renderResult = __bind(this.renderResult, this);
        this.renderQuestion = __bind(this.renderQuestion, this);
        this.render = __bind(this.render, this);        _ref = MainPage.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      MainPage.prototype.className = 'main-page';

      MainPage.prototype.templateHtml = $('#main-page-tmpl').html();

      MainPage.prototype.initialize = function() {
        app.on('getResult', this.renderResult);
        return app.movies = new Movies;
      };

      MainPage.prototype.render = function() {
        this.$el.html(this.templateHtml);
        this.content = this.$el.find('.content');
        this.renderQuestion();
        return this;
      };

      MainPage.prototype.renderQuestion = function() {
        var questionView;

        questionView = new QuestionView();
        return this.content.empty().append(questionView.render().el);
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
