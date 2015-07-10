var _                   = require('underscore'),
    Backbone            = require('backbone'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Answer = Backbone.Model.extend({
    defaults: function defaults () {
        return { selected: false };
    },

    initialize: function () {
      _.bindAll(this, 'toggleSelection');
    },

    toggleSelection: function toggleSelection () {
        this.set('selected', !this.get('selected'));
    },
});

var AnswerStore = Backbone.Collection.extend({
    model: Answer,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'selectAnswer');
        this.dispatchToken = UserGuideDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_ANSWERS:
                this.set(payload.data);
                break;
            case ActionTypes.SELECT_ANSWER:
                this.selectAnswer(payload.data);
                break;
        }
    },

    selectAnswer: function selectAnswer (data) {
        var answer   = this.findWhere({ guide_question_id: data.question_id, id: data.answer_id });
        var selected = this.findWhere({ guide_question_id: data.question_id, selected: true });

        answer.toggleSelection();
        selected.toggleSelection();

        this.trigger('change');
    },
});

module.exports = new AnswerStore();
