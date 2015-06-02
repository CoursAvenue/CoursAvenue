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

    toggleSubjectFilter: function toggleSubjectFilter (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_SUBJECT_FILTERS
        });
    }
};
