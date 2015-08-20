var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    /*
     * @params data: { card: CardModel }
     */
    cardHovered: function cardHovered (hovered) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.CARD_HOVERED,
            data: hovered
        });
    },

    /*
     * @params number: 14
     */
    updateNbCardsPerPage: function updateNbCardsPerPage (number) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UPDATE_NB_CARDS_PER_PAGE,
            data: number
        });
    },

    /*
     * @params data: { card: CardModel }
     */
    highlightMarker: function highlightMarker (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.HIGHLIGHT_MARKER,
            data: data
        });
    },

    unhighlightMarkers: function unhighlightMarkers () {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.UNHIGHLIGHT_MARKERS
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

    dismissHelp: function dismissHelp (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.DISMISS_HELP,
            data: data,
        });
    },

    toggleDismiss: function dismissHelp (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_DISMISS_HELP,
            data: data,
        });
    },

    toggleFavorite: function toggleFavorite (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_FAVORITE,
            data: data,
        });
    },
};
