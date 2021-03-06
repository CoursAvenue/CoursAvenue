var _                   = require('lodash'),
    Backbone            = require('backbone'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Question = Backbone.Model.extend({});

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
        }
    },
});

module.exports = new QuestionStore();
