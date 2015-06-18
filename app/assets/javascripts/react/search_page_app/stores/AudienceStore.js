var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

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
    },

    toggleAudienceSelection: function toggleAudienceSelection (audience) {
        this.trigger('change');
    },
});

module.exports = new AudienceStore([
    { id: 'audience.kid',    name: 'Enfants' },
    { id: 'audience.adult',  name: 'Adultes' },
    { id: 'audience.senior', name: 'Séniors' },
]);
