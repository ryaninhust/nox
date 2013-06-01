(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'lodash', 'backbone'], function($, _, backbone) {
    var Question, _ref;

    Question = (function(_super) {
      __extends(Question, _super);

      function Question() {
        _ref = Question.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      Question.prototype.defaults = {
        question: '额，这并不是个问题, 这是个bug。。。',
        headUrl: ' ',
        type: ' '
      };

      return Question;

    })(Backbone.Model);
    return Question;
  });

}).call(this);
