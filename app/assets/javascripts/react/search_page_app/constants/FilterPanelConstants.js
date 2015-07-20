var keyMirror = require('keymirror');

module.exports = {
    FILTER_PANELS: keyMirror({
        SUBJECTS         : null,
        LOCATION         : null,
        TIME             : null,
        MORE             : null,
        SUBJECT_FULL_TEXT: null
    }),

    SUBJECT_PANELS: keyMirror({
        GROUP: null,
        ROOT:  null,
        CHILD: null
    }),

    LOCATION_PANELS: keyMirror({
        ADDRESS: null,
        METRO:  null
    }),

    TIME_PANELS: keyMirror({
        LESSON:   null,
        TRAINING: null
    }),

};
