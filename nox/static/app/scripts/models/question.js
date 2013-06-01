(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'lodash', 'backbone'], function($, _, backbone) {
    var Question, _ref;

    Question = (function(_super) {
      __extends(Question, _super);

      function Question() {
        this.selectmovie = __bind(this.selectmovie, this);
        this.toRenderJSON = __bind(this.toRenderJSON, this);        _ref = Question.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Question.prototype.defaults = {
        question: '额，这并不是个问题, 这是个bug。。。',
        headUrl: ' ',
        type: ' ',
        movies: [
          {
            name: 'aaa',
            cover_url: 'http://img3.douban.com/view/photo/photo/public/p1812483670.jpg',
            director: 'kk',
            summary: 'xxxxxx'
          }, {
            name: 'bb',
            cover_url: 'http://img3.douban.com/view/photo/photo/public/p1812483670.jpg',
            director: 'houkanshan',
            summary: 'xxxxxx'
          }
        ]
      };

      Question.prototype.toRenderJSON = function() {
        var movie, question;

        question = this.toJSON();
        movie = this.selectmovie(question.movies);
        question.movie = movie;
        return question;
      };

      Question.prototype.selectmovie = function(movies) {
        return movies[0];
      };

      return Question;

    })(Backbone.Model);
    return Question;
  });

}).call(this);
