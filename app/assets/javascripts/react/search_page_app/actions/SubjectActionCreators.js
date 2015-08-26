var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {

    selectGroupSubjectById: function selectGroupSubjectById (subject_group_id) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_GROUP_SUBJECT_BY_ID,
            data: parseInt(subject_group_id, 10) // Ensure it's an integer
        });
    },
    /*
     * subject_group: Hash as { group_id, name }
     */
    selectGroupSubject: function selectGroupSubject (subject_group) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_GROUP_SUBJECT,
            data: subject_group
        });
    },

    /*
     * root_subject: Hash as { slug, name }
     */
    selectRootSubject: function selectRootSubject (root_subject) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_ROOT_SUBJECT,
            data: root_subject
        });
    },

    /*
     * subject: Hash as { slug, name }
     */
    selectSubject: function selectSubject (subject) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SELECT_SUBJECT,
            data: subject
        });
    },

    selectNextSuggestion: function selectNextSuggestion () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.FULL_TEXT_SELECT_NEXT_SUGGESTION
        });
    },

    selectPreviousSuggestion: function selectPreviousSuggestion () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.FULL_TEXT_SELECT_PREVIOUS_SUGGESTION
        });
    },

    selectPreviousSuggestionList: function selectPreviousSuggestionList () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.FULL_TEXT_SELECT_PREVIOUS_SUGGESTION_LIST
        });
    },

    selectNextSuggestionList: function selectNextSuggestionList () {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.FULL_TEXT_SELECT_NEXT_SUGGESTION_LIST
        });
    },

    selectSuggestion: function selectSuggestion (list_name, index) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.FULL_TEXT_SELECT_SUGGESTION,
            data: { list_name: list_name, index: index}
        });
    },

    searchFullText: function searchFullText (data) {
        SearchPageDispatcher.dispatch({
            actionType: SearchPageConstants.ActionTypes.SUBJECT_SEARCH_FULL_TEXT,
            data: data
        });
    },
};
