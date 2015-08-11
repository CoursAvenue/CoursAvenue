var _                   = require('lodash'),
    Backbone            = require('backbone'),
    AnswerStore         = require('./AnswerStore'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var COLORS = {
    'danse':                           '#f6705f',
    'theatre-scene':                   '#d85f79',
    'musique-chant':                   '#c66fa2',
    'cuisine-vins':                    '#375b76',
    'yoga-bien-etre-sante':            '#4f99d0',
    'sports-arts-martiaux':            '#3ec5dd',
    'photo-video':                     '#d5905c',
    'deco-mode-bricolage':             '#ec9f53',
    'dessin-peinture-arts-plastiques': '#f0c15c',
}

var Subject = Backbone.Model.extend({
    defaults: function defaults () {
        return { score: 0, selected: false, age_details: [] };
    },

    initialize: function initialize () {
        _.bindAll(this, 'updateScore', 'searchUrl', 'getColor');
    },

    updateScore: function updateScore (answer) {
        this.set('score', this.get('score') + answer.get('ponderation'));
    },

    searchUrl: function searchUrl (city) {
        if (!city) { city = 'Paris'; }
        var city_slug = city.toLowerCase().replace(/[^a-z0-9]+/g,'-').replace(/(^-|-$)/g,'');

        return Routes.search_page_path(this.get('root_slug'), this.get('slug'), city);
    },

    getColor: function getColor () {
        return COLORS[this.get('root_slug')];
    },

});

var SubjectStore = Backbone.Collection.extend({
    model: Subject,
    // Order by score ASC.
    comparator: 'score',
    DELTA_FOR_RELEVANT_SUBJECTS: 10,

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

    // As the collection is sorted by score, the most relevent subject is the last one
    getMostRelevantSubject: function getMostRelevantSubject (data) {
        return this.last();
    },

    // Other relevant subjects are other subjects that the same score than the most relevant with
    // a delta of DELTA_FOR_RELEVANT_SUBJECTS
    getOtherRelevantSubjects: function getOtherRelevantSubjects (data) {
        var best_score      = this.last().get('score');
        var best_subject_id = this.last().get('id');
        return _.take(this.select(function(subject) {
            return (subject.get('score') > best_score - this.DELTA_FOR_RELEVANT_SUBJECTS &&
                    subject.get('id') != best_subject_id);
        }.bind(this)), 5);
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
    }
});

module.exports = new SubjectStore();
