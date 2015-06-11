var _                    = require('underscore'),
    Backbone             = require('backbone'),
    FilterStore          = require('../stores/FilterStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var PlanningModel = Backbone.Model.extend({});

var PlanningCollection = Backbone.Collection.extend({
    model  : PlanningModel,
    loading: false,
    error  : false,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'planningSearchSuccess', 'planningSearchError');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        if (this.isEmpty()) { this.fetchDataFromServer(); }
        AlgoliaSearchUtils.cards_search_helper.on( "result", this.planningSearchSuccess);
        AlgoliaSearchUtils.cards_search_helper.on( "error", this.planningSearchError);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.UPDATE_FILTERS:
                SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                this.fetchDataFromServer();
                break;
        }
    },

    planningSearchSuccess: function planningSearchSuccess (data) {
        this.loading = false;
        this.reset(data.hits);
    },

    planningSearchError: function planningSearchError () {
        this.loading = false;
        this.error   = true;
        this.trigger('change');
    },

    fetchDataFromServer:  function fetchDataFromServer () {
        this.error   = false;
        this.loading = true;
        this.trigger('change');
        // AlgoliaSearchUtils.searchPlannings(FilterStore.getPlanningFiltersForAlgolia());
    }

});

// the Store is an instantiated Collection; a singleton.
// module.exports = new PlanningCollection();
