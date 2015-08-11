var _                  = require('lodash'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var MessageModel = Backbone.Model.extend({});

var MessageStore = Backbone.Collection.extend({
    model: MessageModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_STRUCTURE_SLUG:
                this.structure_slug = payload.data;
                this.loadThreads();
                break;
        }
    },

    loadThreads: function loadThreads () {
        this.loading = true;
        $.get(Routes.structure_community_message_threads_path(this.structure_slug), function(data) {
            this.loading     = false;
            this.reset(data.comments);
        }.bind(this), 'json');
    }
});

module.exports = new MessageStore();
