var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    updateBounds: function updateBounds (bounds) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_BOUNDS,
            data: bounds
        });
    },
    /*
     * address: Hash with |
     *      latitude:
     *      longitude:
     *      name:
     *      is_address: Boolean // Tells wether it's an address or just a bootstraped city
     */
    filterByAddress: function filterByAddress (address) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_ADDRESS,
            data: address
        });
    },

    locateUser: function locateUser () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.LOCATE_USER
        });
    }
};
