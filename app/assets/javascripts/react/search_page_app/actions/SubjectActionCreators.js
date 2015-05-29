var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    selectSubject: function selectSubject (subject_slug) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_SUBJECT,
            data: subject_slug
        });
    }
};
