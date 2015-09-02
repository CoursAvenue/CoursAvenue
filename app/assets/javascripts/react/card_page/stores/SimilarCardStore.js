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
        _.bindAll(this, 'dispatchCallback', 'setCard', 'searchSuccess', 'searchError');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
        this.card = null;
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.BOOTSTRAP_SIMILAR_PROFILES:
                this.setCard(payload.data);
                break;
        }
    },

    setCard: function setCard (card) {
        this.card = card;
        this.loadSimilarCards();
    },

    loadSimilarCards: function loadSimilarCards () {
        if (!this.card) { return ; }
        this.loading = true;
        var filters = {
            subjects:          this.card.subjects,
            indexable_card_id: this.card.id,
            aroundLatLng: this.card.position.lat + ',' + this.card.position.lng,
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
