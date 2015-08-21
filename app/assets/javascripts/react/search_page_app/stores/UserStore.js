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
        _.bindAll(this, 'dispatchCallback', 'log_in', 'log_out', 'asyncLogin',
                        'setFavorites', 'toggleFavorite', 'favorites');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);

        $(window).on('user:connection', this.asyncLogin.bind(this));
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

    asyncLogin: function asyncLogin (event, data) {
        if (this.get('logged_in')) { return ; }
        this.set('logged_in', true);
        this.set('favorites', _.uniq(this.get('favorites').concat(data.favorite_card_ids)));
    },

    log_out: function log_out () {
        this.set('logged_in', false);
    },

    setFavorites: function setFavorites (favorites) {
        this.set('favorites', favorites);
    },

    addFavorite: function addFavorite (card) {
        if (this.get('logged_in')) {
            $.post(Routes.structure_indexable_card_favorite_path(
                card.get('structure_slug'), card.get('slug'), { format: 'json' }
            ));
        } else {
            // Show connection alert or something.
        }

        var favorites = this.get('favorites') || [];
        favorites.push(card.id);
        this.set('favorites', favorites);
    },

    removeFavorite: function removeFavorite (card) {
        if (this.get('logged_in')) {
            $.ajax({
                url: Routes.structure_indexable_card_favorite_path(
                    card.get('structure_slug'), card.get('slug'), { format: 'json' }
                ),
                type: 'DELETE'
            });
        } else {
        }

        var favorites = _.uniq(this.get('favorites'));
        var index = _.indexOf(favorites, card.id);

        if (index != -1) { favorites.splice(index, 1); }

        this.set('favorites', favorites);
    },

    toggleFavorite: function toggleFavorite (data) {
        var card = data.card;
        if (_.includes(this.get('favorites'), card.id)) {
            this.removeFavorite(card);
        } else {
            this.addFavorite(card);
        }
    },

    favorites: function favorites () {
        return this.get('favorites');
    },
});

module.exports = new User();