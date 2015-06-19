var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var Level = Backbone.Model.extend({
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

var LevelStore = Backbone.Collection.extend({
    model: Level,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.TOGGLE_LEVEL:
                this.toggleLevelSelection(payload.data);
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'levels') {
                    this.map(function(level) {
                        level.set({ selected: false }, { silent: true });
                    });
                    this.trigger('change');
                }
                break;
        }
    },

    toggleLevelSelection: function toggleLevelSelection (level) {
        level.toggleSelection();
        this.trigger('change');
    },

    algoliaFilters: function algoliaFilters () {
        var filters = this.map(function(model) {
            if (model.get('selected')) {
                return (model.get('id'));
            }
        });
        filters = _.compact(filters);

        if (_.isEmpty(filters)) {
            return false;
        }

        return filters;
    },

});

module.exports = new LevelStore([
    { id: 'level.all',          name: 'All' },
    { id: 'level.beginner',     name: 'Beginner' },
    { id: 'level.intermediate', name: 'Intermediate' },
    { id: 'level.confirmed',    name: 'Confirmed' },
    { id: 'level.professional', name: 'Professional' }
]);
