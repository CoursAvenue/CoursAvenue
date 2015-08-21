var _                  = require('lodash'),
    Backbone           = require('backbone'),
    StructureStore     = require('../stores/StructureStore'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    AlgoliaSearchUtils = require('../utils/AlgoliaSearchUtils'),
    ActionTypes        = CardPageConstants.ActionTypes;

var StructureModel = Backbone.Model.extend({
});

var SimilarProfileStore = Backbone.Collection.extend({
    model: StructureModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'searchSuccess', 'searchError');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_STRUCTURE:
                CardPageDispatcher.waitFor([StructureStore.dispatchToken]);
                this.loadSimilarProfiles();
                break;
        }
    },

    loadSimilarProfiles: function loadSimilarProfiles () {
        this.loading = true;
        var filters = {};
        AlgoliaSearchUtils.searchCards(filters, this.searchSuccess, this.searchError);
    },

    searchSuccess: function searchSuccess (data) {
        this.loading = false;
        this.error   = false;

        this.reset(data);
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },
});

module.exports = new SimilarProfileStore();
