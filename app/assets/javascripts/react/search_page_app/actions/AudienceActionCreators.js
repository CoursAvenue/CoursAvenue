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

    /*
     * @audiences ['kid', 'adult']
     */
    setAudiences: function setAudiences (audiences) {
        if (_.isString(audiences)) { audiences = [audiences] }
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_AUDIENCES,
            data: audiences
        });
    }
};
