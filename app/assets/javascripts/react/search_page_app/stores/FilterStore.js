var _                    = require('underscore')
    Backbone             = require('Backbone'),
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

    getPlanningFiltersForAlgolia: function getPlanningFiltersForAlgolia () {
        var data = {};
        if (this.get('subject')) { data.subject = this.get('subject').slug }
        if (this.get('insideBoundingBox')) {
            data.insideBoundingBox = this.get('insideBoundingBox').toString();
        }
        if (this.get('user_position')) {
            data.aroundLatLng = this.get('user_position').latitude + ',' + this.get('user_position').longitude;
        } else if (this.get('city')) {
            data.aroundLatLng = this.get('city').latitude + ',' + this.get('city').longitude;
        }
        return data;
    },
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
