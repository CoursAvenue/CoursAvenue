var CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

module.exports = {
    populateCourse: function populateCourse (structure_id, course_id) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_COURSE,
            data: { structure_id: structure_id, course_id: course_id }
        });
    },

    populateIndexableCard: function populateIndexableCard (structure_id, indexable_card_id) {
        CardPageDispatcher.dispatch({
            actionType: ActionTypes.POPULATE_INDEXABLE_CARD,
            data: { structure_id: structure_id, indexable_card_id: indexable_card_id }
        });
    },
};
