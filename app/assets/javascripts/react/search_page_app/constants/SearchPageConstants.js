var keyMirror = require('keymirror');

module.exports = {

    ActionTypes: keyMirror({
        FILTERS__MAP_BOUNDS_CHANGED: null,

        LOAD_PLANNINGS:              null,
        LOAD_PLANNINGS_SUCCESS:      null,
        LOAD_PLANNINGS_FAILURE:      null
    })
};
