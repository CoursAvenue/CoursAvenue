var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    selectGroupSubject: function selectGroupSubject (subject_group) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_GROUP_SUBJECT,
            data: subject_group
        });
    },

    selectRootSubject: function selectRootSubject (root_subject) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_ROOT_SUBJECT,
            data: root_subject
        });
    },

    selectSubject: function selectSubject (subject) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_SUBJECT,
            data: subject
        });
    }
};
