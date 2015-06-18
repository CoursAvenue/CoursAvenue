var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var PriceStore = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'setBounds', 'algoliaFilters');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_PRICE_BOUNDS:
                this.setBounds(payload.data);
                break;
        }
    },

    setBounds: function setBounds (bounds) {
        // This should trigger the change event, and update stuff if needed.
        this.set('bounds', bounds);
    },

    algoliaFilters: function algoliaFilters () {
        var bounds = this.get('bounds');
        if (!bounds || _.isEmpty(bounds)) { return false; }

        return bounds;
    },
});

module.exports = new PriceStore();
