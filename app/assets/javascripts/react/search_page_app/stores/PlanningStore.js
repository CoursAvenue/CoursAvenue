var Backbone             = require('Backbone'),
    FilterStore          = require('../stores/FilterStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var PlanningModel = Backbone.Model.extend({});

var PlanningCollection = Backbone.Collection.extend({
    model: PlanningModel,
    loading: false,
    error: false,
    //url: "/todo",
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        if (this.isEmpty()) { this.fetchDataFromServer(); }
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.UPDATE_FILTERS:
                SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                this.fetchDataFromServer();
                break;
        }
    },

    fetchDataFromServer:  function fetchDataFromServer () {
        this.loading = true;
        this.trigger('change');
        AlgoliaSearchUtils.searchPlannings(FilterStore.getPlanningFilters()).then(function(content){
            this.loading = false;
            this.reset(content.hits);
        }.bind(this)).catch(function(error) {
            this.loading = false;
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    }

});

// the Store is an instantiated Collection; a singleton.
module.exports = new PlanningCollection();
