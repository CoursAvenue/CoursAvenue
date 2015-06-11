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

    toggleSubjectFilter: function toggleSubjectFilter () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_SUBJECT_FILTERS
        });
    },

    showGroupPanel: function showGroupPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_GROUP_PANEL
        });
    },

    showRootPanel: function showRootPanel () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SHOW_ROOT_PANEL
        });
    }
};