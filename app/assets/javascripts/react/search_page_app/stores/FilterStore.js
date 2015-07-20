var _                    = require('lodash'),
    Backbone             = require('backbone'),
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
            case ActionTypes.SHOW_METRO_PANEL:
                this.set({ location_panel: FilterPanelConstants.LOCATION_PANELS.METRO });
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
            case ActionTypes.SELECT_ADDRESS:
            case ActionTypes.LOCATE_USER:
            case ActionTypes.CLOSE_FILTER_PANEL:
                this.unset('current_panel');
                break;
            case ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:
            case ActionTypes.CLOSE_SUBJECT_INPUT_PANEL:
                if (this.get('old_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS) {
                    this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.SUBJECTS);
                } else {
                    this.unset('current_panel');
                }
                break;
            case ActionTypes.SEARCH_FULL_TEXT:
            case ActionTypes.SHOW_SUBJECT_INPUT_PANEL:
                if (!this.get('current_panel') || this.get('current_panel') != FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT) {
                    this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT);
                }
                break;
            case ActionTypes.SELECT_SUBJECT:
                this.unset('current_panel');
                this.set({ subject_panel: FilterPanelConstants.SUBJECT_PANELS.CHILD });
                break;
            case ActionTypes.TOGGLE_SUBJECT_FILTERS:
                this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.SUBJECTS);
                break;
            case ActionTypes.TOGGLE_LOCATION_FILTERS:
                this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.LOCATION);
                break;
            case ActionTypes.TOGGLE_TIME_FILTERS:
                this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.TIME);
                break;
            case ActionTypes.TOGGLE_MORE_FILTERS:
                this.setCurrentPanel(FilterPanelConstants.FILTER_PANELS.MORE);
                break;
            case ActionTypes.UNSET_FILTER:
                this.unsetFilter(payload.data);
                break;
            case ActionTypes.CHANGE_CONTEXT:
                this.changeContext(payload.data);
                break;
        }
    },

    setCurrentPanel: function setCurrentPanel (panel) {
        var current_panel = this.get('current_panel');
        if (panel == current_panel) {
            this.unset('current_panel');
        } else {
            this.set({ old_panel: current_panel });
            this.set({ current_panel: panel });
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
    },

    changeContext: function changeContext (new_context) {
        if (new_context == 'training') {
            this.set('time_panel', FilterPanelConstants.TIME_PANELS.TRAINING);
        } else {
            this.set('time_panel', FilterPanelConstants.TIME_PANELS.LESSON);
        }
    },
});

// the Store is an instantiated Collection; a singleton.
module.exports = new FilterStore();
