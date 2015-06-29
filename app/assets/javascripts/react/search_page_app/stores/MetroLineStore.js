var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes,
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
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'metro') {
                    this.unsetLine();
                }
                break;
            case ActionTypes.LOCATE_USER:
            case ActionTypes.SELECT_ADDRESS:
                this.unsetLine();
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
    { name: 'Ligne 1',     slug: 'ligne-1',     number: '1', is_bis: false  },
    { name: 'Ligne 2',     slug: 'ligne-2',     number: '2', is_bis: false  },
    { name: 'Ligne 3',     slug: 'ligne-3',     number: '3', is_bis: false  },
    { name: 'Ligne 3 Bis', slug: 'ligne-3-bis', number: '3 Bis', is_bis: true  },
    { name: 'Ligne 4',     slug: 'ligne-4',     number: '4', is_bis: false  },
    { name: 'Ligne 5',     slug: 'ligne-5',     number: '5', is_bis: false  },
    { name: 'Ligne 6',     slug: 'ligne-6',     number: '6', is_bis: false  },
    { name: 'Ligne 7',     slug: 'ligne-7',     number: '7', is_bis: false  },
    { name: 'Ligne 7 Bis', slug: 'ligne-7-bis', number: '7 Bis', is_bis: true  },
    { name: 'Ligne 8',     slug: 'ligne-8',     number: '8', is_bis: false  },
    { name: 'Ligne 9',     slug: 'ligne-9',     number: '9', is_bis: false  },
    { name: 'Ligne 10',    slug: 'ligne-10',    number: '10', is_bis: false  },
    { name: 'Ligne 11',    slug: 'ligne-11',    number: '11', is_bis: false  },
    { name: 'Ligne 12',    slug: 'ligne-12',    number: '12', is_bis: false  },
    { name: 'Ligne 13',    slug: 'ligne-13',    number: '13', is_bis: false  },
    { name: 'Ligne 14',    slug: 'ligne-14',    number: '14', is_bis: false  },
]);
