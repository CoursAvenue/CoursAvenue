var UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

module.exports = {
    populateAnswers: function populateAnswers (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_ANSWERS,
            data: data
        });
    },
    selectAnswer: function selectAnswer (data) {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.SELECT_ANSWER,
            data: data
        });
    },
}
