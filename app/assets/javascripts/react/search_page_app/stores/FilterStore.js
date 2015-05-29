var Backbone             = require('Backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var FilterStore = Backbone.Model.extend({

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_SUBJECT:
                this.set({ subject_slug: payload.data });
                break;
            case ActionTypes.UPDATE_FILTERS:
                this.set(payload);
                break;
        }
    },
    getPlanningFilters: function getPlanningFilters () {
        return {};
    },
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
