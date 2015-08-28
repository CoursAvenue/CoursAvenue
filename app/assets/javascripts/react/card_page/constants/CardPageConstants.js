var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        BOOTSTRAP_COURSE:              null,
        POPULATE_COURSE:               null,
        POPULATE_INDEXABLE_CARD:       null,
        BOOTSTRAP_SIMILAR_PROFILES:    null,

        SUBMIT_REQUEST:                null,
        SUBMIT_NEW_THREAD:             null,
        REPLY_TO_THREAD:               null,

        SET_STRUCTURE:                 null,

        COMMENT_GO_TO_PAGE:            null,
        COMMENT_GO_TO_PREVIOUS_PAGE:   null,
        COMMENT_GO_TO_NEXT_PAGE:       null,

        ADD_CARD_TO_FAVORITES:         null,
        ADD_STRUCTURE_TO_FAVORITES:    null,

        REMOVE_CARD_TO_FAVORITES:      null,
        REMOVE_STRUCTURE_TO_FAVORITES: null,
    })

};
