var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        SEARCH:                      null,
        CLEAR_ALL_THE_DATA:          null,
        FILTERS__MAP_BOUNDS_CHANGED: null,

        CHANGE_CONTEXT:              null,

        TOGGLE_SUBJECT_FILTERS:      null,
        TOGGLE_LOCATION_FILTERS:     null,
        TOGGLE_TIME_FILTERS:         null,
        TOGGLE_MORE_FILTERS:         null,
        CLOSE_FILTER_PANEL:          null,
        CLOSE_SUBJECT_INPUT_PANEL:   null,
        SHOW_SUBJECT_INPUT_PANEL:    null,

        SELECT_GROUP_SUBJECT:        null,
        SELECT_ROOT_SUBJECT:         null,
        SELECT_SUBJECT:              null,
        SELECT_ADDRESS:              null,
        SEARCH_FULL_TEXT:            null,
        SELECT_METRO_LINES:          null,
        SELECT_METRO_LINE:           null,
        SELECT_METRO_STOP:           null,
        INIT_SEARCH_FULL_TEXT:       null,

        UNSET_FILTER:                null,

        SHOW_GROUP_PANEL:            null,
        SHOW_ROOT_PANEL:             null,

        SHOW_ADDRESS_PANEL:          null,
        SHOW_LOCATION_CHOICE_PANEL:  null,
        SHOW_METRO_PANEL:            null,

        TOGGLE_MAP_FULLSCREEN:       null,

        UPDATE_FILTERS:              null,
        UPDATE_BOUNDS:               null,

        LOCATE_USER:                 null,

        CARD_HOVERED:                null,
        HIGHLIGHT_MARKER:            null,
        UNHIGHLIGHT_MARKERS:         null,

        TOGGLE_DAY_SELECTION:        null,
        TOGGLE_PERIOD_SELECTION:     null,
        TOGGLE_PERIODS_SELECTION:    null,
        SET_TRAINING_DATE:           null,
        SET_TRAINING_START_DATE:     null,
        SET_TRAINING_END_DATE:       null,

        TOGGLE_AUDIENCE:             null,
        SET_AUDIENCES:               null,
        SET_PRICE_BOUNDS:            null,
        TOGGLE_LEVEL:                null,
        SET_LEVELS:                  null,

        GO_TO_PREVIOUS_PAGE:         null,
        GO_TO_NEXT_PAGE:             null,
        GO_TO_PAGE:                  null,

        UPDATE_SORTING:              null
    })

};
