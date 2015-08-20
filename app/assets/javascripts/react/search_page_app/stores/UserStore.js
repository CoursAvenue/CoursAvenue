var _                    = require('lodash'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var User = Backbone.Model.extend({
    defaults: function defaults () {
	return { favorites: [], logged_in: false };
    },

    initialize: function initialize () {
	_.bindAll(this, 'dispatchCallback', 'log_in', 'log_out',
			'setFavorites', 'toggleFavorite', 'favorites');
	this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
	switch(payload.actionType) {
	    case ActionTypes.TOGGLE_FAVORITE:
		this.toggleFavorite(payload.data);
		break;
	}
    },

    log_in: function log_in () {
	this.set('logged_in', true);
    },

    log_out: function log_in () {
	this.set('logged_in', false);
    },

    setFavorites: function setFavorites (favorites) {
	this.set('favorites', favorites);
    },

    toggleFavorite: function toggleFavorite (data) {
	var card = data.card;
	if (this.get('logged_in')) {
	    $.post(Routes.toggle_favorite_structure_indexable_card_path(
		card.get('structure_slug'), card.get('slug'), { format: 'json' }
	    ));
	} else {
	    // Show connection alert or something.
	}

	var favorites = this.get('favorites');
	if (_.includes(favorites, card.id)) {
	    var index = _.indexOf(favorites, card.id);
	    favorites.splice(index, 1);
	} else {
	    favorites.push(card.id);
	}
	this.set('favorites', favorites);
    },

    favorites: function favorites () {
	return this.get('favorites');
    },
});

module.exports = new User();
