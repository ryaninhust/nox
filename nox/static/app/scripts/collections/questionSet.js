(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'lodash', 'backbone', 'models/question'], function($, _, backbone, Question) {
    var QuestionSet, _ref;

    QuestionSet = (function(_super) {
      __extends(QuestionSet, _super);

      function QuestionSet() {
        _ref = QuestionSet.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      QuestionSet.prototype.model = Question;

      QuestionSet.prototype.initialize = function() {
        return this;
      };

      return QuestionSet;

    })(Backbone.Collection);
    return QuestionSet;
  });

}).call(this);
