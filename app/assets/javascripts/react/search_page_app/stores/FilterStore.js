var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SubjectStore         = require('../stores/SubjectStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
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
            case ActionTypes.UPDATE_FILTERS:
                this.set(payload.data);
                break;
            case ActionTypes.SHOW_GROUP_PANEL:
                this.set({ subject_panel: 'group' });
                break;
            case ActionTypes.SHOW_ROOT_PANEL:
                this.set({ subject_panel: 'root' });
                break;
            case ActionTypes.SELECT_GROUP_SUBJECT:
                this.set({ group_subject: payload.data });
                this.set({ root_subject: null });
                this.set({ subject: null });
                this.set({ subject_panel: 'root' });
                this.set({ group_subject: payload.data });
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.set({ root_subject: payload.data });
                this.set({ subject_panel: 'child' });
                this.fetchDataFromServer();
                break;
            case ActionTypes.SELECT_SUBJECT:
                this.set({ subject: payload.data });
                this.fetchDataFromServer();
                this.trigger('change');
                break;
            case ActionTypes.TOGGLE_SUBJECT_FILTERS:
                this.current_panel = (this.current_panel == 'subjects' ? null : 'subjects');
                this.trigger('change');
                break;
        }
    },

    getSelectedRootSubject: function getSelectedRootSubject () {
        return null;
    },

    getSelectedSubject: function getSelectedSubject () {
        return null;
    },

    algoliaFilters: function algoliaFilters () {
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

    cardFilters: function cardFilters () {
        return this.toJSON();
    },

    fetchDataFromServer: function fetchDataFromServer () {

    },

    getFilters: function getFilters () {
        var filters = [];
        if (this.get('group_subject')) {
            filters.push({ title: this.get('group_subject').name, filter_key: 'group_subject' });
        }
        if (this.get('root_subject')) {
            filters.push({ title: this.get('root_subject').name, filter_key: 'root_subject' });
        }
        if (this.get('subject')) {
            filters.push({ title: this.get('subject').name, filter_key: 'subject' });
        }
        return filters;
    }
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
