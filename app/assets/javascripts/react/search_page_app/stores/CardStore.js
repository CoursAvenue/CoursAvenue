var _                    = require('underscore'),
    Backbone             = require('backbone'),
    FilterStore          = require('../stores/FilterStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var CardModel = Backbone.Model.extend({});

var CardCollection = Backbone.Collection.extend({
    model:   CardModel,
    loading: false,
    error:   false,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'searchSuccess', 'searchError');

        // Register the store to the dispatcher, so it calls our callback on new actions.
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);

        // Bind search events to the store, so it updates.
        AlgoliaSearchUtils.card_search_helper.on("result",  this.searchSuccess);
        AlgoliaSearchUtils.card_search_helper.on("error",  this.searchError);
    },

    // The function called everytime there's a new action dispatched.
    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            // When the filters are updated, refetch the cards.
            case ActionTypes.UPDATE_FILTERS:
            case ActionTypes.SELECT_GROUP_SUBJECT:
            case ActionTypes.SELECT_ROOT_SUBJECT:
            case ActionTypes.SELECT_SUBJECT:
            case ActionTypes.SEARCH_FULL_TEXT:
            case ActionTypes.UNSET_FILTER:
                // Make sure the Filter store has finish everything he needs to do.
                SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                // Fetch the new cards.
                this.fetchDataFromServer();
                break;
            case ActionTypes.HIGHLIGHT_MARKER:
                // console.log('highlight maker');
                break;
            case ActionTypes.UNHIGHLIGHT_MARKER:
                // console.log('unhighlight maker');
                break;
        }
    },

    fetchDataFromServer: function fetchDataFromServer () {
        this.error   = false;
        this.loading = true;

        this.trigger('change');

        // Call the algolia search.
        AlgoliaSearchUtils.searchCards(FilterStore.algoliaFilters());
    }.debounce(150),

    searchSuccess: function searchSuccess (data) {
        this.loading = false;
        this.error   = false;

        // This triggers the change event.
        this.facets        = data.facets;
        this.total_results = data.nbHits;
        this.reset(data.hits);
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },
});

module.exports = new CardCollection();