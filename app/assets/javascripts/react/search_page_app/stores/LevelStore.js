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
            case ActionTypes.SET_LEVELS:
                this.setLevels(payload.data);
                break;
            case ActionTypes.TOGGLE_LEVEL:
                this.toggleLevelSelection(payload.data);
                break;
            case ActionTypes.CLEAR_ALL_THE_DATA:
                this.unsetLevels();
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'levels') { this.unsetLevels(); }
                break;
        }
    },

    unsetLevels: function unsetLevels () {
        this.map(function(level) {
            level.set({ selected: false }, { silent: true });
        });
        this.trigger('change');
    },

    setLevels: function setLevels (levels) {
        _.map(levels, function(level) {
            this.findWhere({ id: level }).set('selected', true);
        }, this)
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
    { id: 'level.all',          name: 'Tous niveaux' },
    { id: 'level.beginner',     name: 'Débutant' },
    { id: 'level.intermediate', name: 'Intermédiaire' },
    { id: 'level.confirmed',    name: 'Avancé' },
    { id: 'level.professional', name: 'Professionnel' }
]);
