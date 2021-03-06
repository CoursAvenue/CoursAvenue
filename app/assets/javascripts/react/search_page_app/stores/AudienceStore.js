var _                    = require('lodash'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var Audience = Backbone.Model.extend({
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

var AudienceStore = Backbone.Collection.extend({
    model: Audience,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_AUDIENCES:
                this.setAudiences(payload.data);
                break;
            case ActionTypes.TOGGLE_AUDIENCE:
                this.toggleAudienceSelection(payload.data);
                break;
            case ActionTypes.CLEAR_ALL_THE_DATA:
                this.unsetAudiences();
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'audiences') { this.unsetAudiences(); }
                break;
        }
    },

    unsetAudiences: function unsetAudiences (audiences) {
        this.map(function(audience) {
            audience.set({ selected: false }, { silent: true });
        });
        this.trigger('change');
    },

    setAudiences: function setAudiences (audiences) {
        _.map(audiences, function(audience) {
            this.findWhere({ id: audience }).set('selected', true);
        }, this)
    },

    toggleAudienceSelection: function toggleAudienceSelection (audience) {
        audience.toggleSelection();
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

module.exports = new AudienceStore([
    { id: 'audience.kid',    name: 'Enfants' },
    { id: 'audience.adult',  name: 'Adultes' },
    { id: 'audience.senior', name: 'Séniors' },
]);
