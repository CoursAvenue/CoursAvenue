var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    selectCity: function selectCity (city) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_CITY,
            data: city
        });
    }
};
