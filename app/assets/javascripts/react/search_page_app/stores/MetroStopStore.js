var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var METRO_LINES = [
    { name: 'Ligne 1',     slug: 'ligne-1' },
    { name: 'Ligne 2',     slug: 'ligne-2' },
    { name: 'Ligne 3',     slug: 'ligne-3' },
    { name: 'Ligne 3 Bis', slug: 'ligne-3-bis' },
    { name: 'Ligne 4',     slug: 'ligne-4' },
    { name: 'Ligne 5',     slug: 'ligne-5' },
    { name: 'Ligne 6',     slug: 'ligne-6' },
    { name: 'Ligne 7',     slug: 'ligne-7' },
    { name: 'Ligne 7 Bis', slug: 'ligne-7-bis' },
    { name: 'Ligne 8',     slug: 'ligne-8' },
    { name: 'Ligne 9',     slug: 'ligne-9' },
    { name: 'Ligne 10',    slug: 'ligne-10' },
    { name: 'Ligne 11',    slug: 'ligne-11' },
    { name: 'Ligne 12',    slug: 'ligne-12' },
    { name: 'Ligne 13',    slug: 'ligne-13' },
    { name: 'Ligne 14',    slug: 'ligne-14' },
];

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
        return METRO_LINES;
    },

    // When receiving the metro line to filter the stops by, we refetch the results if needed.
    fetchMetroStops: function fetchMetroStops (metro_line) {
        if (this.metro_line == metro_line) { return ; }

        this.metro_line = _.findWhere(METRO_LINES, { slug: metro_line });

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
