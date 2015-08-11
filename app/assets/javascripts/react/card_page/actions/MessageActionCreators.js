var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {

    /*
     * @param data { message: 'lorem...' }
     */
    submitThread: function submitThread (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.SUBMIT_NEW_THREAD,
            data: data
        });
    },

    /*
     * @param data { id: XX, message: 'lorem...' }
     */
    replyToThread: function replyToThread (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.REPLY_TO_THREAD,
            data: data
        });
    },

}
