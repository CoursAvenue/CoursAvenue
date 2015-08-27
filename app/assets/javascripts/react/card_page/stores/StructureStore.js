var _                  = require('lodash'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var StructureStore = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_STRUCTURE:
                this.set(payload.data);
                break;
            case ActionTypes.REMOVE_STRUCTURE_TO_FAVORITES:
                this.removeFromFavorites(payload.data);
                break;
            case ActionTypes.ADD_STRUCTURE_TO_FAVORITES:
                this.addToFavorites(payload.data);
                break;
        }
    },

    addToFavorites: function addToFavorites (data) {
        $.ajax({
            url: Routes.add_to_favorite_structure_path(data.structure_id, { format: 'json' }),
            type: 'POST',
            success: function success (response) {
                this.set('favorited', true);
            }.bind(this),
        });
    },

    removeFromFavorites: function removeFromFavorites (data) {
        $.ajax({
            url: Routes.remove_from_favorite_structure_path(data.structure_id, { format: 'json' }),
            type: 'POST',
            success: function success (response) {
                this.set('favorited', false);
            }.bind(this),
        });
    },

});

module.exports = new StructureStore();
