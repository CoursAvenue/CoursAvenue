var Backbone             = require('Backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var FilterStore = Backbone.Model.extend({

    toJSON: function toJSON () {
        var attributes = _.clone(this.attributes);
        if (attributes.insideBoundingBox) {
            attributes.insideBoundingBox = attributes.insideBoundingBox.toString();
        }
        return attributes;
    },

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.set({ subject_slug: payload.data });
                break;
            case ActionTypes.UPDATE_FILTERS:
                this.set(payload.data);
                break;
        }
    },
    getPlanningFilters: function getPlanningFilters () {
        return this.toJSON();
    },
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
