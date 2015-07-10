var _                   = require('underscore'),
    Backbone            = require('backbone'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Question = Backbone.Model.extend({
    initialize: function initialize () {
    },
});

var QuestionStore = Backbone.Collection.extend({
    model: Question,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = UserGuideDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_QUESTION:
                this.set(payload.data);
                break;
            case ActionTypes.NEXT_QUESTION:
                console.log('ok');
                break;
        }
    },
});

module.exports = new QuestionStore();
