var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    toggleLevel: function toggleAudience (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_LEVEL,
            data: data
        });
    },
};
