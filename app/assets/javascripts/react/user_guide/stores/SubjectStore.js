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
            case ActionTypes.SELECT_SUBJECT:
                this.selectSubject(payload.data);
                break;
            case ActionTypes.DESELECT_SUBJECT:
                this.deselectSubject(payload.data);
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

    selectSubject: function selectSubject (data) {
        debugger
        this.trigger('change')
    },

    deselectSubject: function deselectSubject (data) {
        debugger
        this.trigger('change')
    },

});

module.exports = new SubjectStore();
