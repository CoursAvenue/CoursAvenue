var _                  = require('lodash'),
    Backbone           = require('backbone'),
    PlanningStore      = require('../stores/PlanningStore'),
    CourseStore        = require('../stores/CourseStore'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var RequestStore = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    url: function url () {
        return Routes.structure_participation_requests_path({ structure_id: this.get('structure_id') });
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
});

module.exports = new RequestStore();
