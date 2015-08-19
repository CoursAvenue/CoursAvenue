var CoursAvenueDispatcher = require('../dispatcher/CoursAvenueDispatcher'),
    CoursAvenueConstants  = require('../constants/CoursAvenueConstants'),
    ActionTypes           = CoursAvenueConstants.ActionTypes;

module.exports = {
    /*
     * @params locations: [{ lat:, ... }]
     */
    bootstrapLocations: function bootstrapLocations (locations) {
        CoursAvenueDispatcher.dispatch({
            actionType: ActionTypes.BOOTSTRAP_LOCATIONS,
            data: locations
        });
    },

    highlightLocation: function highlightLocation (place_id) {
        CoursAvenueDispatcher.dispatch({
            actionType: ActionTypes.HIGHLIGHT_LOCATION,
            data: place_id
        });
    },

    unhighlightLocation: function unhighlightLocation (place_id) {
        CoursAvenueDispatcher.dispatch({
            actionType: ActionTypes.UNHIGHLIGHT_LOCATION,
            data: place_id
        });
    },
};
