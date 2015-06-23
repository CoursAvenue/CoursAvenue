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

// http://mattjmcnaughton.com/aloglia-and-backbone-js
var MetroStopStore = Backbone.Collection.extend({
    model: MetroStop,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'metroLines', 'fetchMetroStops', 'selectMetroStop');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.metro_line = null;
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_METRO_LINE:
                this.fetchMetroStops(payload.data);
                break;
            case ActionTypes.SELECT_METRO_STOP:
                this.selectMetroStop(payload.data);
                break;
        }
    },

    metroLines: function metroLines () {
        return [
            { name: 'Ligne 1', slug: 'ligne-1' },
            { name: 'Ligne 2', slug: 'ligne-2' },
            { name: 'Ligne 3', slug: 'ligne-3' },
            { name: 'Ligne 4', slug: 'ligne-4' },
            { name: 'Ligne 5', slug: 'ligne-5' }
        ];
    },

    // When receiving the metro line to filter the stops by, we refetch the results if needed.
    fetchMetroStops: function fetchMetroStops (metro_line) {
        if (this.metro_line == metro_line) {
            return ;
        }

        this.metro_line = metro_line;
        // TODO: Fetch the metro stops and store them in the collection.
        this.set([ { name: 'Faidherbe-Chaligny', slug: 'faidherbe-chaligny' } ]);

        this.trigger('change');
    },

    selectMetroStop: function selectMetroStop (metro_stop_slug) {
        var current_stop = this.findWhere({ selected: true });
        var metro_stop   = this.findWhere({ slug: metro_stop_slug });

        if (current_stop) { current_stop.toggleSelection(); }
        if (metro_stop)   { metro_stop.toggleSelection(); }
        this.trigger('change');
    },

    getSelectedStop: function getSelectedStop () {
        return this.findWhere({ selected: true });
    },
});

module.exports = new MetroStopStore();
