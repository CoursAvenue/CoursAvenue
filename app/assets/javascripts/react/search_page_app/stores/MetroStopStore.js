var _                    = require('underscore'),
    algoliasearch        = require('algoliasearch'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    MetroLineStore       = require('./MetroLineStore'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var client = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    index  = client.initIndex('Metro_Stop_' + ENV.SERVER_ENVIRONMENT);


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
        _.bindAll(this, 'dispatchCallback', 'fetchMetroStops',
                        'selectMetroStop', 'unsetStop', 'getSelectedStop');

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
            case ActionTypes.LOCATE_USER:
            case ActionTypes.SELECT_ADDRESS:
                this.unsetStop();
                break;
        }
    },

    // When receiving the metro line to filter the stops by, we refetch the results if needed.
    fetchMetroStops: function fetchMetroStops (metro_line) {
        this.metro_line = MetroLineStore.getSelectedLine();

        index.search('', {
            facets:      '*',
            facetFilters: ['metro_lines.line:' + this.metro_line.get('slug')],
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
