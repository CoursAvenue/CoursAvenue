var _                   = require('lodash'),
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
        _.bindAll(this, 'dispatchCallback', 'selectAnswer', 'selectAge', 'getAges', 'selectedAge');
        this.selected_age = null;
        this.answers = [];
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
            case ActionTypes.SELECT_AGE:
                this.selectAge(payload.data);
                break;
        }
    },

    selectAnswer: function selectAnswer (data) {
        var answer   = this.findWhere({ guide_question_id: data.question_id, id: data.answer_id });
        var selected = this.findWhere({ guide_question_id: data.question_id, selected: true });

        if (answer) {
            answer.toggleSelection();
            this.answers.push({ question: data.question_index + 1, answer: data.answer_index + 1 });
        }
        if (selected) { selected.toggleSelection(); }

        this.trigger('change');
    },

    selectAge: function selectAge (data) {
        this.selected_age = data.age
        this.trigger('change');
    },

    getAges: function getAges () {
        return [
            { id: 'younger-than-5',  content: 'Moins de 5 ans' },
            { id: 'between-5-and-9', content: 'de 5 à 9 ans' },
            { id: 'older-than-10',   content: '10 ans ou plus' }
        ];
    },

    selectedAge: function selectedAge () {
        return _.findWhere(this.getAges(), { id: this.selected_age });
        return false;
    },
});

module.exports = new AnswerStore();
