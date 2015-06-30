var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    toggleAudience: function toggleAudience (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_AUDIENCE,
            data: data
        });
    },
};
