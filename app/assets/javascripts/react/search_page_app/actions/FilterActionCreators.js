var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

module.exports = {

    clearAllTheData: function clearAllTheData (context) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.CLEAR_ALL_THE_DATA
        });
    },

    search: function search (context) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SEARCH
        });
    },

    /*
     * @param context: course|training
     */
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

    showSearchInputPanel: function showSearchInputPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SHOW_SUBJECT_INPUT_PANEL
        });
    },

    clearFullTextAndCloseSearchInputPanel: function clearFullTextAndCloseSearchInputPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL
        });
    },

    closeSearchInputPanel: function closeSearchInputPanel () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.CLOSE_SUBJECT_INPUT_PANEL
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

    initSearchFullText: function initSearchFullText (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.INIT_SEARCH_FULL_TEXT,
            data: data
        });
    },

    searchFullText: function searchFullText (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SEARCH_FULL_TEXT,
            data: data
        });
    },

    /*
     * @metro_lines 'line-14'
     */
    selectMetroLine: function selectMetroLine (metro_line) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SELECT_METRO_LINE,
            data: metro_line
        });
    },

    /*
     * @metro_lines ['line-14', 'rer-a']
     */
    selectMetroLines: function selectMetroLine (metro_lines) {
        // Ensure we have an array
        if (_.isString(metro_lines)) { metro_lines = [metro_lines]; }
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SELECT_METRO_LINES,
            data: metro_lines
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
    },

    remoteLastFilter: function remoteLastFilter (filter) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.REMOVE_LAST_FILTER,
            data: filter,
        });
    },
};
