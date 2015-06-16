var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    ActionTypes          = SearchPageConstants.ActionTypes;


module.exports = {
    toggleDaySelection: function toggleDaySelection (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_DAY_SELECTION,
            data: data
        });
    },

    togglePeriodSelection: function togglePeriodSelection (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_PERIOD_SELECTION,
            data: data
        });
    },
};
