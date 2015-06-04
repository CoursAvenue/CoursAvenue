var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        FILTERS__MAP_BOUNDS_CHANGED: null,

        TOGGLE_SUBJECT_FILTERS:      null,
        SELECT_ROOT_SUBJECT:         null,
        UPDATE_FILTERS:              null,

        HIGHLIGHT_MARKER:            null,
        UNHIGHLIGHT_MARKER:          null
    })

};
