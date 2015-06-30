var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {
    submitRequest: function submitRequest (data) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.SUBMIT_REQUEST,
            data: data
        });
    },
};
