var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        POPULATE_COURSE    : null,
        POPULATE_PLANNINGS : null,

        SUBMIT_REQUEST     : null,

        SET_STRUCTURE_SLUG : null,

        GO_TO_PAGE         : null,
        GO_TO_PREVIOUS_PAGE: null,
        GO_TO_NEXT_PAGE    : null
    })

};
