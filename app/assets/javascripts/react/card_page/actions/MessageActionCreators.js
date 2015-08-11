var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {
    setStructureSlug: function setStructureSlug (structure_slug) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.SET_STRUCTURE_SLUG,
            data: structure_slug
        });
    }
}
