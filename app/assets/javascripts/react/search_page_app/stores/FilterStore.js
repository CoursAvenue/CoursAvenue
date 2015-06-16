var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SubjectStore         = require('../stores/SubjectStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FilterPanelConstants = require('../constants/FilterPanelConstants');

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
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.GROUP });
                break;
            case ActionTypes.SHOW_ROOT_PANEL:
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.ROOT });
                break;
            case ActionTypes.SELECT_GROUP_SUBJECT:
                this.set({ group_subject: payload.data });
                this.set({ root_subject: null });
                this.set({ subject: null });
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.ROOT });
                this.set({ group_subject: payload.data });
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.set({ root_subject: payload.data });
                if (!this.get('group_subject')) { this.setGroupSubject(); }
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.CHILD });
                break;
            case ActionTypes.SELECT_SUBJECT:
                this.set({ subject: payload.data });
                this.trigger('change');
                break;
            case ActionTypes.SELECT_CITY:
                this.set({ city: payload.data });
                break;
            case ActionTypes.SEARCH_FULL_TEXT:
                this.set({ full_text_search: payload.data });
                break;
            case ActionTypes.TOGGLE_SUBJECT_FILTERS:
                this.set({ current_panel: (this.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS ? null : FilterPanelConstants.FILTER_PANELS.SUBJECTS) });
                break;
            case ActionTypes.TOGGLE_LOCATION_FILTERS:
                this.set({ current_panel: (this.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION ? null : FilterPanelConstants.FILTER_PANELS.LOCATION) });
                break;
            case ActionTypes.TOGGLE_TIME_FILTERS:
                this.set({ current_panel: (this.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME ? null : FilterPanelConstants.FILTER_PANELS.TIME) });
                break;
            case ActionTypes.UNSET_FILTER:
                this.unsetFilter(payload.data);
                break;
        }
    },

    unsetFilter: function unsetFilter (filter_to_unset) {
        // Change subject_panel_to show regarding the filter we unset
        // If we unset root subject, we can't show child subject panel because we don't have
        // root subject information
        switch(filter_to_unset) {
            case 'group_subject':
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.GROUP });
                break;
            case 'root_subject':
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.ROOT });
                break;
            case 'subject':
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.CHILD });
                break;
        }
        this.unset(filter_to_unset);
    },
    setGroupSubject: function setGroupSubject () {
        var group_subject = SubjectStore.getGroupSubjectFromRootSubjectSlug(this.get('root_subject').slug);
        this.set({ group_subject: group_subject});
    },

    algoliaFilters: function algoliaFilters () {
        var data = {};
        if (this.get('group_subject'))     { data.group_subject    = this.get('group_subject') }
        if (this.get('root_subject'))      { data.root_subject     = this.get('root_subject') }
        if (this.get('subject'))           { data.subject          = this.get('subject') }
        if (this.get('full_text_search'))  { data.full_text_search = this.get('full_text_search') }
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

    // Filters used to build the TimeTable.
    timeFilters: function timeFilters () {
        return {};
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
        if (this.get('full_text_search')) {
            filters.push({ title: "Activité : " + this.get('full_text_search'), filter_key: 'full_text_search' });
        }
        return filters;
    },

    // Checks if we are filtering around a place (e.g. User location, Around a subway stop, etc.)
    // TODO: Add metro stop check.
    isFilteringAroundLocation: function isFilteringAroundLocation () {
        return ! (_.isUndefined(this.get('user_position')) || _.isNull(this.get('user_position')));
    }
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
