var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants');
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {
    populateCourse: function populateCourse (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_COURSE,
            data: data
        });
    },
};
