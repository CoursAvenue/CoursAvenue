var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    /*
     * @bounds [min_price, max_price]
     */
    setPriceBounds: function setPriceBounds (bounds) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_PRICE_BOUNDS,
            data: bounds
        });
    },
};
