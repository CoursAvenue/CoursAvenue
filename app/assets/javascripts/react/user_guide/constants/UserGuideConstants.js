var keyMirror = require('keymirror');

module.exports = {
    ActionTypes: keyMirror({
        NEXT_QUESTION: null,

        POPULATE_ANSWERS:  null,
        POPULATE_SUBJECTS: null,
        POPULATE_QUESTION: null,

        SELECT_AGE:    null,
        SELECT_ANSWER: null
    })
};
