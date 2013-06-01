(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['app', 'jquery', 'lodash', 'backbone', 'collections/questionSet', 'models/question'], function(app, $, _, Backbone, QuestionSet, Question) {
    var QuestionView, _ref;

    return QuestionView = (function(_super) {
      __extends(QuestionView, _super);

      function QuestionView() {
        _ref = QuestionView.__super__.constructor.apply(this, arguments);
        return _ref;
      }

      QuestionView.prototype.className = 'dialog-wrapper';

      QuestionView.prototype.template = _.template($('#question-dialog-tmpl').html());

      QuestionView.prototype.collection = new QuestionSet();

      QuestionView.prototype.currentQuestion = new Question();

      QuestionView.prototype.events = {
        'click button[type=submit]': 'answerQuestion'
      };

      QuestionView.prototype.initialize = function() {
        this.collection.on('add', this.gotNewQuestion, this);
        return this.getQuestion();
      };

      QuestionView.prototype.render = function() {
        var question;

        question = this.currentQuestion.toRenderJSON();
        this.$el.html(this.template(question));
        return this;
      };

      QuestionView.prototype.gotNewQuestion = function(model, collection) {
        this.currentQuestion = model;
        this.render();
        return this;
      };

      QuestionView.prototype.getQuestion = function(answer) {
        var _this = this;

        if (answer == null) {
          answer = {};
        }
        return $.post('/get_question', answer).done(function(r) {
          if (r.type === 'question') {
            return _this.addQuestion(r);
          } else {
            return app.trigger('getResult', r);
          }
        }).fail(function(r) {
          var _ref1;

          if ((_ref1 = _this.trick) == null) {
            _this.trick = '是么？那';
          }
          _this.trick += '那';
          r = {
            type: 'question',
            question: _this.trick + '你吃过测试么？'
          };
          return _this.addQuestion(r);
        });
      };

      QuestionView.prototype.answerQuestion = function(e) {
        var answer;

        e = $(e.target);
        answer = {
          value: e.val()
        };
        this.getQuestion(answer);
        return this;
      };

      QuestionView.prototype.addQuestion = function(gotQuestion) {
        var queston;

        queston = new Question(gotQuestion);
        this.collection.add(queston);
        return this;
      };

      return QuestionView;

    })(Backbone.View);
  });

}).call(this);
