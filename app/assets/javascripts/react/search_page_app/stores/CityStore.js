var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var CityStore = Backbone.Model.extend({

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_CITY:
                this.set(payload.data);
                break;
        }
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new CityStore();
