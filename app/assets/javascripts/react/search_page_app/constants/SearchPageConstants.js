var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        FILTERS__MAP_BOUNDS_CHANGED: null,

        TOGGLE_SUBJECT_FILTERS:      null,
        SELECT_GROUP_SUBJECT:        null,
        SELECT_ROOT_SUBJECT:         null,
        SELECT_SUBJECT:              null,

        SHOW_GROUP_PANEL:            null,
        SHOW_ROOT_PANEL:             null,

        UPDATE_FILTERS:              null,

        HIGHLIGHT_MARKER:            null,
        UNHIGHLIGHT_MARKER:          null
    })

};
