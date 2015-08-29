var _                    = require('lodash'),
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
        _.bindAll(this, 'dispatchCallback', 'selectLine', 'unsetSelectedLines');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_METRO_LINES:
                _.each(payload.data, function(metro_line){
                    this.selectLine(metro_line);
                }, this);
                break;
            case ActionTypes.SELECT_METRO_LINE:
                this.selectLine(payload.data);
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'metro') {
                    this.unsetSelectedLines();
                }
                break;
            case ActionTypes.CLEAR_ALL_THE_DATA:
            case ActionTypes.LOCATE_USER:
            case ActionTypes.SELECT_ADDRESS:
                this.unsetSelectedLines();
                break;
            case ActionTypes.REMOVE_LAST_FILTER:
                if (this == payload.data) {
                    this.unsetSelectedLines();
                }
                break;
        }
    },

    selectLine: function selectLine (metro_line_slug) {
        var current_line = this.findWhere({ selected: true });
        var metro_line   = this.findWhere({ slug: metro_line_slug });

        if (metro_line)   { metro_line.toggleSelection(); }
        this.trigger('change');
    },

    getSelectedLines: function getSelectedLines () {
        return this.where({ selected: true });
    },

    unsetSelectedLines: function unsetSelectedLines () {
        _.invoke(this.where({ selected: true }), 'toggleSelection');
        this.trigger('change');
    },
});

module.exports = new MetroLineStore([
    // Metros
    { name: 'Ligne 1',     slug: 'ligne-1',     number: '1',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 2',     slug: 'ligne-2',     number: '2',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 3',     slug: 'ligne-3',     number: '3',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 3 Bis', slug: 'ligne-3-bis', number: '3 Bis', line_type: 'metro', is_bis: true  },
    { name: 'Ligne 4',     slug: 'ligne-4',     number: '4',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 5',     slug: 'ligne-5',     number: '5',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 6',     slug: 'ligne-6',     number: '6',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 7',     slug: 'ligne-7',     number: '7',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 7 Bis', slug: 'ligne-7-bis', number: '7 Bis', line_type: 'metro', is_bis: true  },
    { name: 'Ligne 8',     slug: 'ligne-8',     number: '8',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 9',     slug: 'ligne-9',     number: '9',     line_type: 'metro', is_bis: false  },
    { name: 'Ligne 10',    slug: 'ligne-10',    number: '10',    line_type: 'metro', is_bis: false  },
    { name: 'Ligne 11',    slug: 'ligne-11',    number: '11',    line_type: 'metro', is_bis: false  },
    { name: 'Ligne 12',    slug: 'ligne-12',    number: '12',    line_type: 'metro', is_bis: false  },
    { name: 'Ligne 13',    slug: 'ligne-13',    number: '13',    line_type: 'metro', is_bis: false  },
    { name: 'Ligne 14',    slug: 'ligne-14',    number: '14',    line_type: 'metro', is_bis: false  },

    // Tram
    { name: 'Tramway 2',   slug: 'tramway-2',   number: '2',     line_type: 'tramway', is_bis: false  },
    { name: 'Tramway 3A',  slug: 'tramway-3a',  number: '3a',    line_type: 'tramway', is_bis: false  },
    { name: 'Tramway 3B',  slug: 'tramway-3b',  number: '3b',    line_type: 'tramway', is_bis: false  },

    // RER
    { name: 'RER A',       slug: 'rer-a',       number: 'A',     line_type: 'rer', is_bis: false  },
    { name: 'RER B',       slug: 'rer-b',       number: 'B',     line_type: 'rer', is_bis: false  },
]);
