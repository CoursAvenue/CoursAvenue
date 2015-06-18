var _                    = require('underscore'),
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
            case ActionTypes.TOGGLE_AUDIENCE:
                this.toggleAudienceSelection(payload.data);
                break;
        }
    },

    toggleAudienceSelection: function toggleAudienceSelection (audience) {
        audience.set('selected', !audience.get('selected'));
        this.trigger('change');
    },
});

module.exports = new AudienceStore([
    { id: 'audience.kid',    name: 'Enfants' },
    { id: 'audience.adult',  name: 'Adultes' },
    { id: 'audience.senior', name: 'Séniors' },
]);
