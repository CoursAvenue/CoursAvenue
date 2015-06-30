var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    setPriceBounds: function setPriceBounds (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_PRICE_BOUNDS,
            data: data
        });
    },
};
