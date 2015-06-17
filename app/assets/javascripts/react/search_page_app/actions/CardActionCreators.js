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
            actionType: ActionTypes.UNHIGHLIGHT_MARKER,
            data: data
        });
    },
    goToPage: function goToPage (page_number) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.GO_TO_PAGE,
            data: page_number
        });
    },
    goToPreviousPage: function goToPreviousPage (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.GO_TO_PREVIOUS_PAGE
        });
    },
    goToNextPage: function goToNextPage (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.GO_TO_NEXT_PAGE
        });
    },
};
