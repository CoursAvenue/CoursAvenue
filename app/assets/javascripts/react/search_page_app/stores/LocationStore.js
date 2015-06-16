var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FilterActionCreators = require('../actions/FilterActionCreators'),
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
                this.set('address', payload.data);
                break;
            case ActionTypes.UPDATE_BOUNDS:
                this.set('bounds', payload.data);
                break;
        }
    },
    locateUser: function locateUser (payload) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(location) {
                this.set('user_location', { latitude: location.coords.latitude, longitude: location.coords.longitude });
                FilterActionCreators.updateFilters({ user_location: this.get('user_location') });
            }.bind(this), function() {});
        }
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new LocationStore();
