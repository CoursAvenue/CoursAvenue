var _                  = require('underscore'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants');

var PlanningModel = Backbone.Model.extend({});
var PlanningStore = Backbone.Collection.extend({
    model: PlanningModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_PLANNINGS:
                this.reset(payload.data);
                break;
        }
    }
});

module.exports = new PlanningStore();
