var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    highlightMarker: function highlightMarker (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.HIGHLIGHT_MARKER,
            data: data
        });
    },

    unHighlightMarker: function highlightMarker (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UNHIGHLIGHT_MARKER
            data: data
        });
    },
};
