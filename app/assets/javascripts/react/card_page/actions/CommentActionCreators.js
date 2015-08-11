var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {

    goToPage: function goToPage (page_number) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.COMMENT_GO_TO_PAGE,
            data: page_number
        });
    },

    goToPreviousPage: function goToPreviousPage (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.COMMENT_GO_TO_PREVIOUS_PAGE
        });
    },

    goToNextPage: function goToNextPage (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.COMMENT_GO_TO_NEXT_PAGE
        });
    }
}
