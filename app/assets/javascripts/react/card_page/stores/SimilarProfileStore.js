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

    comparator: function comparator (profile) {
        return (- parseInt(profile.get('search_score'), 10));
    },

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
        var filters = {
            aroundLatLng:   StructureStore.get('latitude') + ',' + StructureStore.get('longitude'),
            structure_id:   StructureStore.get('id'),
            structure_slug: StructureStore.get('slug'),
        };

        AlgoliaSearchUtils.searchSimilarSubject(filters, this.searchSuccess, this.searchError);
    }.debounce(150), // Prevent from double loading

    searchSuccess: function searchSuccess (data) {
        this.loading = false;
        this.error   = false;

        this.reset(data.hits);
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },
});

module.exports = new SimilarProfileStore();
