var _                  = require('lodash'),
    Backbone           = require('backbone'),
    CourseStore        = require('../stores/CourseStore'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    AlgoliaSearchUtils = require('../utils/AlgoliaSearchUtils'),
    ActionTypes        = CardPageConstants.ActionTypes;

var Card = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'getVisibleIndex');
    },

    getVisibleIndex: function getVisibleIndex () {
        if (!this.collection) { return 0 };
        return this.collection.indexOf(this) + 1;
    },
});

var SimilarCardStore = Backbone.Collection.extend({
    model: Card,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'searchSuccess', 'searchError');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_INDEXABLE_CARD:
                CardPageDispatcher.waitFor([CourseStore.dispatchToken]);
                this.loadSimilarCards();
                break;
        }
    },

    loadSimilarCards: function loadSimilarCards () {
        this.loading = true;
        var filters = {
            indexable_card_id: CourseStore.first().get('id'),
            // aroundLatLng:   StructureStore.get('latitude') + ',' + StructureStore.get('longitude'),
            // structure_id:   StructureStore.get('id'),
            // structure_slug: StructureStore.get('slug'),
        };

        AlgoliaSearchUtils.searchSimilarCards(filters, this.searchSuccess, this.searchError);
    },

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

module.exports = new SimilarCardStore();
