var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FluxBoneMixin        = require('../../mixins/FluxBoneMixin');

var MetroLine = Backbone.Model.extend({
    defaults: function defaults () {
        return { selected: false };
    },

    initialize: function initialize () {
        _.bindAll(this, 'toggleSelection');
    },

    toggleSelection: function toggleSelection () {
        this.set('selected', !this.get('selected'));
    },
});

var MetroLineStore = Backbone.Collection.extend({
    model: MetroLine,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'selectLine', 'unsetLine');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_METRO_LINE:
                this.selectLine(payload.data);
                break;
            case ActionTypes.LOCATE_USER:
            case ActionTypes.SELECT_ADDRESS:
                this.unsetLine()
                break;
        }
    },

    selectLine: function selectLine (metro_line_slug) {
        var current_line = this.findWhere({ selected: true });
        var metro_line   = this.findWhere({ slug: metro_line_slug });

        if (current_line) { current_line.toggleSelection(); }
        if (metro_line)   { metro_line.toggleSelection(); }
        this.trigger('change');
    },

    getSelectedLine: function getSelectedLine () {
        return this.findWhere({ selected: true });
    },

    unsetLine: function unsetLine () {
        var current_line = this.findWhere({ selected: true });
        if (current_line) { current_line.toggleSelection(); }
        this.trigger('change');
    },
});

module.exports = new MetroLineStore([
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
]);
