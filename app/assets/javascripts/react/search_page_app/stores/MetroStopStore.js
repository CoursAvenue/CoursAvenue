var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var MetroStop = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'coordinates');
    },

    coordinates: function coordinates () {
        return [ this.get('latitude'), this.get('longitude') ];
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
