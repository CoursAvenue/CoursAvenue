var UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    ActionTypes         = UserGuideConstants.ActionTypes;

module.exports = {
    nextQuestion: function nextQuestion () {
        UserGuideDispatcher.dispatch({
            actionType: ActionTypes.NEXT_QUESTION
        });
    },
};
