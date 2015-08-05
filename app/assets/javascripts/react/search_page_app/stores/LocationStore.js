var _                    = require('lodash'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var LocationStore = Backbone.Model.extend({

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.set({ fullscreen: false });
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.LOCATE_USER:
                this.locateUser();
                break;
            case ActionTypes.SELECT_METRO_LINES:
            case ActionTypes.SELECT_METRO_LINE:
            case ActionTypes.SELECT_METRO_STOP:
                this.unset('user_location');
                this.unset('address');
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
                break;
            case ActionTypes.FINDING_USER_LOCATION:
                this.set({ finding_user_position: true });
                break;
            case ActionTypes.USER_LOCATION_FOUND:
                this.set({ finding_user_position: false });
                break;
            case ActionTypes.USER_LOCATION_NOT_FOUND:
                this.unset('user_location');
            case ActionTypes.USER_LOCATION_FOUND:
                this.set({ finding_user_position: false });
                break;
            case ActionTypes.UNSET_FILTER:
                if      (payload.data == 'user_location') { this.unset('user_location'); }
                else if (payload.data == 'address') { this.unset('address'); }
                break;
            case ActionTypes.TOGGLE_MAP_FULLSCREEN:
                this.set({ fullscreen: !this.get('fullscreen') });
                break;
        }
    },

    locateUser: function locateUser (payload) {
        this.set({ finding_user_position: true });
        this.set({ user_location: true });
    },

    isUserLocated: function isUserLocated (payload) {
        return !_.isUndefined(this.get('user_location'));
    },

    isFilteredByAddress: function isFilteredByAddress (payload) {
        return !_.isUndefined(this.get('address')) && this.get('address').is_address;
    },

    getCitySlug: function getCitySlug () {
        if (this.get('address')) {
            if (this.get('address').city) {
                return this.get('address').city.toLowerCase().replace(/ /g,'-').replace(/ème/g,'');
            } else {
                return this.get('address').name.replace(', France','').toLowerCase().replace(/ /g,'-').replace(/ème/g,'');
            }
        } else {
            return 'paris';
        }
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new LocationStore();
