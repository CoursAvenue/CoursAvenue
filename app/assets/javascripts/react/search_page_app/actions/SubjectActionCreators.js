var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    selectRootSubject: function selectRootSubject (subject_slug) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_ROOT_SUBJECT,
            data: subject_slug
        });
    }
};
