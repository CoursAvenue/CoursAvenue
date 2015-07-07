var _                    = require('underscore'),
    algoliasearch        = require('algoliasearch'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes,
    MetroLineStore       = require('./MetroLineStore'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var client = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    index  = client.initIndex('Ratp_Stop_' + ENV.SERVER_ENVIRONMENT);


var MetroStop = Backbone.Model.extend({
    defaults: function defaults () {
        return { selected: false };
    },

    initialize: function initialize () {
        _.bindAll(this, 'coordinates', 'toggleSelection');
    },

    coordinates: function coordinates () {
        return [ this.get('_geoloc').lat, this.get('_geoloc').lng ];
    },

    toggleSelection: function toggleSelection () {
        this.set('selected', !this.get('selected'));
    },
});

var MetroStopStore = Backbone.Collection.extend({
    model: MetroStop,

    comparator: function comparator (stop) {
        var line = _.findWhere(stop.get('metro_lines'), { line: this.metro_lines[0].get('slug') });
        return (line.position);
    },

    initialize: function initialize () {
        _.bindAll(this, 'comparator', 'dispatchCallback',
                  'fetchMetroStops', 'selectMetroStop', 'unsetStop', 'getSelectedStop');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.metro_line = null;
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_METRO_LINE:
                SearchPageDispatcher.waitFor([MetroLineStore.dispatchToken]);
                this.fetchMetroStops(payload.data);
                break;
            case ActionTypes.SELECT_METRO_STOP:
                this.selectMetroStop(payload.data);
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'metro') {
                    this.unsetStop();
                }
                break;
            case ActionTypes.CLEAR_ALL_THE_DATA:
            case ActionTypes.LOCATE_USER:
            case ActionTypes.SELECT_ADDRESS:
                this.unsetStop();
                break;
        }
    },

    // When receiving the metro line to filter the stops by, we refetch the results if needed.
    fetchMetroStops: function fetchMetroStops (metro_line) {
        this.metro_lines = MetroLineStore.getSelectedLines();
        // Don't fetch stops if there is more than 1 selected line
        if (this.metro_lines.length != 1) { return; }
        index.search('', {
            facets:      '*',
            facetFilters: ['metro_lines.line:' + this.metro_lines[0].get('slug')],
            hitsPerPage: 100,
        }, function(err, results) {
            this.reset(results.hits);
            this.trigger('change');
        }.bind(this));
    },

    selectMetroStop: function selectMetroStop (metro_stop_slug) {
        var current_stop = this.findWhere({ selected: true });
        var metro_stop   = this.findWhere({ slug: metro_stop_slug });

        if (metro_stop == current_stop) { return ; }

        if (current_stop) { current_stop.toggleSelection(); }
        if (metro_stop)   { metro_stop.toggleSelection(); }
        this.trigger('change');
    },

    getSelectedStop: function getSelectedStop () {
        return this.findWhere({ selected: true });
    },

    unsetStop: function unsetStop () {
        if (!this.getSelectedStop()) { return ; }
        var current_stop = this.findWhere({ selected: true });

        if (current_stop) { current_stop.toggleSelection(); }
        this.trigger('change');
    },
});

module.exports = new MetroStopStore();
