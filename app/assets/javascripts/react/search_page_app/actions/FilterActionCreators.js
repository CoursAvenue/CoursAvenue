var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    updateFilters: function updateFilters (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_FILTERS,
            data: data
        });
    },

    updateSorting: function updateSorting (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_SORTING,
            data: data
        });
    },

    closeFilterPanel: function closeFilterPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.CLOSE_FILTER_PANEL
        });
    },

    toggleSubjectFilter: function toggleSubjectFilter () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_SUBJECT_FILTERS
        });
    },

    toggleLocationFilter: function toggleLocationFilter () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_LOCATION_FILTERS
        });
    },

    toggleTimeFilter: function toggleTimeFilter () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_TIME_FILTERS
        });
    },

    toggleMoreFilter: function toggleMoreFilter () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_MORE_FILTERS
        });
    },

    //----------- Subject panels
    showGroupPanel: function showGroupPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_GROUP_PANEL
        });
    },

    showRootPanel: function showRootPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_ROOT_PANEL
        });
    },

    //----------- Location panels
    showAddressPanel: function showAddressPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_ADDRESS_PANEL
        });
    },

    showLocationChoicePanel: function showLocationChoicePanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_LOCATION_CHOICE_PANEL
        });
    },

    searchFullText: function searchFullText (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SEARCH_FULL_TEXT,
            data: data
        });
    },

    unsetFilter: function unsetFilter (filter_key) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UNSET_FILTER,
            data: filter_key
        });
    }
};
