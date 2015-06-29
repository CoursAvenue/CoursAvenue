var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants');
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {
    populatePlannings: function populatePlannings (planning) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_PLANNINGS,
            data: planning
        });
    },

    bookPlanning: function bookPlanning (planning) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.BOOK_PLANNING,
            data: planning
        });
    },
};
