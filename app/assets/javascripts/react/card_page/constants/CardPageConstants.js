var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        POPULATE_COURSE    : null,
        POPULATE_PLANNINGS : null,

        SUBMIT_REQUEST     : null,
        SUBMIT_NEW_THREAD  : null,
        REPLY_TO_THREAD    : null,

        SET_STRUCTURE      : null,

        COMMENT_GO_TO_PAGE         : null,
        COMMENT_GO_TO_PREVIOUS_PAGE: null,
        COMMENT_GO_TO_NEXT_PAGE    : null
    })

};
