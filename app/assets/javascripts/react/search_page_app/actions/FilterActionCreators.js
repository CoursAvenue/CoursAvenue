var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

module.exports = {

    changeContext: function changeContext (context) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.CHANGE_CONTEXT,
            data: context
        });
    },

    updateFilters: function updateFilters (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.UPDATE_FILTERS,
            data: data
        });
    },

    updateSorting: function updateSorting (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.UPDATE_SORTING,
            data: data
        });
    },

    closeFilterPanel: function closeFilterPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.CLOSE_FILTER_PANEL
        });
    },

    toggleSubjectFilter: function toggleSubjectFilter () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.TOGGLE_SUBJECT_FILTERS
        });
    },

    toggleLocationFilter: function toggleLocationFilter () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.TOGGLE_LOCATION_FILTERS
        });
    },

    toggleTimeFilter: function toggleTimeFilter () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.TOGGLE_TIME_FILTERS
        });
    },

    toggleMoreFilter: function toggleMoreFilter () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.TOGGLE_MORE_FILTERS
        });
    },

    //----------- Subject panels
    showGroupPanel: function showGroupPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_GROUP_PANEL
        });
    },

    showRootPanel: function showRootPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_ROOT_PANEL
        });
    },

    //----------- Location panels
    showAddressPanel: function showAddressPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_ADDRESS_PANEL
        });
    },

    showLocationChoicePanel: function showLocationChoicePanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_LOCATION_CHOICE_PANEL
        });
    },

    showMetroPanel: function showMetroPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_METRO_PANEL
        });
    },

    searchFullText: function searchFullText (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SEARCH_FULL_TEXT,
            data: data
        });
    },

    selectMetroLine: function selectMetroLine (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SELECT_METRO_LINE,
            data: data
        });
    },

    selectMetroStop: function selectMetroStop (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SELECT_METRO_STOP,
            data: data
        });
    },

    unsetFilter: function unsetFilter (filter_key) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.UNSET_FILTER,
            data: filter_key
        });
    }
};
