var _                    = require('underscore'),
    Backbone             = require('backbone'),
    LocationStore        = require('../stores/LocationStore'),
    LocationStore        = require('../stores/LocationStore'),
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
            case ActionTypes.SHOW_ADDRESS_PANEL:
                this.set({ location_panel: FilterPanelConstants.LOCATION_PANELS.ADDRESS });
                break;
            case ActionTypes.SHOW_LOCATION_CHOICE_PANEL:
                this.unset('location_panel');
                break;
            case ActionTypes.SELECT_GROUP_SUBJECT:
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.ROOT });
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.CHILD });
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

    // Checks if we are filtering around a place (e.g. User location, Around a subway stop, etc.)
    // TODO: Add metro stop check.
    isFilteringAroundLocation: function isFilteringAroundLocation () {
        return ! (_.isUndefined(this.get('user_location')) || _.isNull(this.get('user_location')));
    }
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
