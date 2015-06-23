var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var MetroStop = Backbone.Model.extend({
    defaults: function defaults () {
        return { selected: false };
    },

    initialize: function initialize () {
        _.bindAll(this, 'coordinates', 'toggleSelection');
    },

    coordinates: function coordinates () {
        return [ this.get('latitude'), this.get('longitude') ];
    },

    toggleSelection: function toggleSelection () {
        this.set('selected', !this.get('selected'));
    },
});

var MetroStopStore = Backbone.Collection.extend({
    model: MetroStop,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
    },
});

module.exports = new MetroStopStore();
