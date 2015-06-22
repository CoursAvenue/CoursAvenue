var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var LocationStore = Backbone.Model.extend({

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.LOCATE_USER:
                this.locateUser();
                this.set('user_location');
                break;
            case ActionTypes.SELECT_ADDRESS:
                this.unset('user_location');
                this.set('address', payload.data);
                break;
            case ActionTypes.UPDATE_BOUNDS:
                this.set('bounds', payload.data);
                break;
            case ActionTypes.UPDATE_FILTERS:
                if (payload.data.user_location) {
                    this.set(payload.data);
                }
            case ActionTypes.UNSET_FILTER:
                if      (payload.data == 'user_location') { this.unset('user_location'); }
                else if (payload.data == 'address') { this.unset('address'); }
                break;
        }
    },

    locateUser: function locateUser (payload) {
        this.set({ user_location: true });
    },

    isUserLocated: function isUserLocated (payload) {
        return !_.isUndefined(this.get('user_location'));
    },

    isFilteredByAddress: function isFilteredByAddress (payload) {
        return !_.isUndefined(this.get('address')) && this.get('address').is_address;
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new LocationStore();
