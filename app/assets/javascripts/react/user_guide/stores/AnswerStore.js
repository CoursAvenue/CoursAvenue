var Backbone            = require('backbone'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Answer = Backbone.Model.extend({
    defaults: function () {
        return { selected: false };
    },

    initialize: function () {
    },
});

var AnswerStore = Backbone.Collection.extend({
    model: Answer,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = UserGuideDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_ANSWERS:
                this.set(payload.data);
                break;
        }
    },
});

module.exports = new AnswerStore();
