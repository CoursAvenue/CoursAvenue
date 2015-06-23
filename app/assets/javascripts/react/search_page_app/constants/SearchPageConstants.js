var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        FILTERS__MAP_BOUNDS_CHANGED: null,

        TOGGLE_SUBJECT_FILTERS:      null,
        TOGGLE_LOCATION_FILTERS:     null,
        TOGGLE_TIME_FILTERS:         null,
        TOGGLE_MORE_FILTERS:         null,
        CLOSE_FILTER_PANEL:          null,

        SELECT_GROUP_SUBJECT:        null,
        SELECT_ROOT_SUBJECT:         null,
        SELECT_SUBJECT:              null,
        SELECT_ADDRESS:              null,
        SEARCH_FULL_TEXT:            null,
        SELECT_METRO_LINE:           null,
        SELECT_METRO_STOP:           null,

        UNSET_FILTER:                null,

        SHOW_GROUP_PANEL:            null,
        SHOW_ROOT_PANEL:             null,

        SHOW_ADDRESS_PANEL:          null,
        SHOW_LOCATION_CHOICE_PANEL:  null,
        SHOW_METRO_PANEL:            null,

        UPDATE_FILTERS:              null,
        UPDATE_BOUNDS:               null,

        LOCATE_USER:                 null,

        HIGHLIGHT_MARKER:            null,
        UNHIGHLIGHT_MARKERS:         null,

        TOGGLE_DAY_SELECTION:        null,
        TOGGLE_PERIOD_SELECTION:     null,
        SET_TRAINING_DATE:           null,

        TOGGLE_AUDIENCE:             null,
        SET_PRICE_BOUNDS:            null,
        TOGGLE_LEVEL:                null,

        GO_TO_PREVIOUS_PAGE:         null,
        GO_TO_NEXT_PAGE:             null,
        GO_TO_PAGE:                  null,

        UPDATE_SORTING:              null
    })

};
