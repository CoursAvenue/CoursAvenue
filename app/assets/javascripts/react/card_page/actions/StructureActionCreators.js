var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {

    setStructure: function setStructure (structure) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.SET_STRUCTURE,
            data: structure
        });
    },

    addToFavorites: function addToFavorites (structure_id, indexable_card_id) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.ADD_STRUCTURE_TO_FAVORITES,
            data: { structure_id: structure_id, indexable_card_id: indexable_card_id }
        });
    },

    removeFromFavorites: function removeFromFavorites (structure_id, indexable_card_id) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.REMOVE_STRUCTURE_TO_FAVORITES,
            data: { structure_id: structure_id, indexable_card_id: indexable_card_id }
        });
    },
}
