var _                  = require('lodash'),
    Backbone           = require('backbone'),
    BackboneValidation = require('backbone-validation'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

_.extend(Backbone.Model.prototype, BackboneValidation.mixin);

var RequestStore = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
        this.on('validated:invalid', function(model, errors) {
            model.set('errors', errors);
        });
    },

    validation: {
        'user.first_name'  : 'presentIfValidateFull',
        'user.last_name'   : 'presentIfValidateFull',
        'user.email'       : 'presentIfValidateFull',
        'user.phone_number': 'presentIfValidateFull'
    },

    presentIfValidateFull: function presentIfValidateFull (value, attr, computed_state) {
        if (this.get('user').validate_full && value.length == 0) {
            return 'Doit être rempli';
        }
    },

    url: function url () {
        // It means that the Request is for unregistered users, then it has to
        // go to a different path
        if (this.get('user').validate_full) {
            return Routes.reservation_structure_participation_requests_path({
              type:         this.get('course_type'),
              structure_id: this.get('structure_id'),
            });
        } else {
            return Routes.structure_participation_requests_path({
              type: this.get('course_type'),
              structure_id: this.get('structure_id')
            });
        }
    },

    // We override the toJSON function to have all the params grouped into
    // `participation_request` when syncing to server
    toJSON: function toJSON () {
        return { participation_request: _.clone(this.attributes) }
    },


    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SUBMIT_REQUEST:
                this.set(payload.data);
                this.submitRequest();
                break;
        }
    },

    submitRequest: function submitRequest () {
        this.unset('errors');
        if (this.isValid(true)) {
            this.unset({ response_popup: false }, { silent: true });
            this.save(null, {
                success: function success (model, response) {
                    this.set({ response_popup: response.popup_to_show });
                }.bind(this),
                error: function error (model, response) {
                    this.set({ response_popup: response.responseJSON.popup_to_show });
                }.bind(this),
            });
        }
    }
});

module.exports = new RequestStore();
