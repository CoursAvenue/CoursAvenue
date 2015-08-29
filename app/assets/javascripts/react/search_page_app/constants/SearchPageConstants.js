var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        SEARCH:                               null,
        CLEAR_ALL_THE_DATA:                   null,
        REMOVE_LAST_FILTER:                   null,
        FILTERS__MAP_BOUNDS_CHANGED:          null,

        CHANGE_CONTEXT:                       null,

        TOGGLE_SUBJECT_FILTERS:               null,
        TOGGLE_LOCATION_FILTERS:              null,
        TOGGLE_TIME_FILTERS:                  null,
        TOGGLE_MORE_FILTERS:                  null,
        CLOSE_FILTER_PANEL:                   null,
        CLOSE_SUBJECT_INPUT_PANEL:            null,
        CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:  null,
        SHOW_SUBJECT_INPUT_PANEL:             null,

        SELECT_GROUP_SUBJECT:                 null,
        SELECT_GROUP_SUBJECT_BY_ID:           null,
        SELECT_ROOT_SUBJECT:                  null,
        SELECT_SUBJECT:                       null,
        SELECT_ADDRESS:                       null,
        SEARCH_FULL_TEXT:                     null,
        SUBJECT_SEARCH_FULL_TEXT:             null,
        SELECT_METRO_LINES:                   null,
        SELECT_METRO_LINE:                    null,
        SELECT_METRO_STOP:                    null,
        INIT_SEARCH_FULL_TEXT:                null,
        FULL_TEXT_SELECT_NEXT_SUGGESTION:     null,
        FULL_TEXT_SELECT_PREVIOUS_SUGGESTION: null,
        FULL_TEXT_SELECT_SUGGESTION:          null,
        FULL_TEXT_SELECT_PREVIOUS_SUGGESTION_LIST: null,
        FULL_TEXT_SELECT_NEXT_SUGGESTION_LIST:     null,

        UNSET_FILTER:                         null,

        SHOW_GROUP_PANEL:                     null,
        SHOW_ROOT_PANEL:                      null,

        SHOW_ADDRESS_PANEL:                   null,
        SHOW_LOCATION_CHOICE_PANEL:           null,
        SHOW_METRO_PANEL:                     null,

        TOGGLE_MAP_FULLSCREEN:                null,

        UPDATE_FILTERS:                       null,
        UPDATE_BOUNDS:                        null,
        UPDATE_BOUNDS_ZOOM:                   null,
        UPDATE_BOUNDS_CENTER:                 null,

        LOCATE_USER:                          null,

        CARD_HOVERED:                         null,
        HIGHLIGHT_MARKER:                     null,
        UNHIGHLIGHT_MARKERS:                  null,

        TOGGLE_DAY_SELECTION:                 null,
        TOGGLE_PERIOD_SELECTION:              null,
        TOGGLE_PERIODS_SELECTION:             null,
        SET_TRAINING_DATE:                    null,
        SET_TRAINING_START_DATE:              null,
        SET_TRAINING_END_DATE:                null,

        TOGGLE_AUDIENCE:                      null,
        SET_AUDIENCES:                        null,
        SET_PRICE_BOUNDS:                     null,
        TOGGLE_LEVEL:                         null,
        SET_LEVELS:                           null,

        GO_TO_PREVIOUS_PAGE:                  null,
        GO_TO_NEXT_PAGE:                      null,
        GO_TO_PAGE:                           null,

        UPDATE_SORTING:                       null,
        UPDATE_NB_CARDS_PER_PAGE:             null,

        DISMISS_HELP:                         null,
        TOGGLE_DISMISS_HELP:                  null,

        TOGGLE_FAVORITE:                      null,
    })

};
