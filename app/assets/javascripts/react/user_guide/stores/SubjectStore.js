var _                   = require('underscore'),
    Backbone            = require('backbone'),
    AnswerStore         = require('./AnswerStore'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Subject = Backbone.Model.extend({
    defaults: function defaults () {
        return { score: 0 };
    },

    initialize: function initialize () {
        _.bindAll(this, 'updateScore');
    },

    updateScore: function updateScore (answer) {
        this.set('score', this.get('score') + answer.get('ponderation'));
    },

});

var SubjectStore = Backbone.Collection.extend({
    model: Subject,
    // Order by score ASC.
    comparator: 'score',

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'updateScores');
        this.dispatchToken = UserGuideDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_SUBJECTS:
                this.set(payload.data);
                break;
            case ActionTypes.SELECT_ANSWER:
                UserGuideDispatcher.waitFor([AnswerStore.dispatchToken]);
                this.updateScores(payload.data);
                break;
        }
    },

    // TODO: Find a way to remove score if it is an updated answer. Only necessary if the user
    // can change her answers to the previous question. If so, we loop on the answers and
    // re-calculate the scores.
    updateScores: function updateScores (data) {
        var answer = AnswerStore.findWhere({ guide_question_id: data.question_id, selected: true });
        if (!answer) { return ; }

        answer.get('subjects').forEach(function(s) {
            var subject = this.findWhere({ id: s.id });
            if (subject) { subject.updateScore(answer); }
        }.bind(this));

        this.sort();
        this.trigger('change');
    },

});

module.exports = new SubjectStore();
