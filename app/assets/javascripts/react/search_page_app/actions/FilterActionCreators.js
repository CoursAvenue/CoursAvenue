var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    updateFilters: function updateFilters (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_FILTERS,
            payload: data
        });
    }
};
