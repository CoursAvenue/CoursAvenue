var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {

    setStructure: function setStructure (structure) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.SET_STRUCTURE,
            data: structure
        });
    }
}
