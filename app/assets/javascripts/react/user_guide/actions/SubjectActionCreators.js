var UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

module.exports = {
    populateSubjects: function populateSubjects (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_SUBJECTS,
            data: data
        });
    },
    selectSubject: function selectSubject (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.SELECT_SUBJECT,
            data: data
        });
    },
    deselectSubject: function deselectSubject (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.DESELECT_SUBJECT,
            data: data
        });
    },
}
