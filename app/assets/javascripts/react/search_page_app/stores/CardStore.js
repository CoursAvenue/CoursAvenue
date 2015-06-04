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
        _.bindAll(this, 'dispatchCallback');

        // Register the store to the dispatcher, so it calls our callback on new actions.
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);

        // Bind search events to the store, so it updates.

        // Initial data fetching.
        if (this.isEmpty()) { this.fetchDataFromServer(); }
    },

    // The function called everytime there's a new action dispatched.
    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.ActionTypes) {
            // When the filters are updated, refetch the cards.
            case ActionTypes.UPDATE_FILTERS:
                // Make sure the Filter store has finish everything he needs to do.
                SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                // Fetch the new cards.
                this.fetchDataFromServer();
                break;
        }
    },

    fetchDataFromServer: function fetchDataFromServer () {
        this.error   = false;
        this.loading = true;

        this.trigger('change');
        // Call the algolia search.
    },

    cardSearchSuccess: function cardSearchSuccess (data) {
        this.loading = false;
        this.error   = false;

        // This triggers the change event.
        this.reset(data.hits);
    },

    cardSearchError: function cardSearchError (data) {
        this.loading = false;
        this.error   = true;
        AlgoliaSearchUtils.searchCards(FilterStore.algoliaCardFilters());
    },
});
