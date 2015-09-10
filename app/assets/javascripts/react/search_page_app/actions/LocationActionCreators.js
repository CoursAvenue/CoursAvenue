var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    // zoom: 12
    updateZoom: function updateZoom (zoom) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_BOUNDS_ZOOM,
            data: zoom
        });
    }.debounce(200),

    // center: { lat: .., lng: ... }
    updateBoundsCenter: function updateBoundsCenter (center) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_BOUNDS_CENTER,
            data: center
        });
    },

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

    userLocationNotFound: function userLocationNotFound () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.USER_LOCATION_NOT_FOUND
        });
    },

    userLocationFound: function userLocationFound () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.USER_LOCATION_FOUND
        });
    },

    locateUser: function locateUser () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.LOCATE_USER
        });
    },

    toggleFullScreen: function toggleFullScreen () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_MAP_FULLSCREEN
        });
    },
};
