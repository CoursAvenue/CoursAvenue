var UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

module.exports = {
    populateSubjects: function populateSubjects (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_SUBJECTS,
            data: data
        });
    }
}
