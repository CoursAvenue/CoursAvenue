var _                     = require('lodash'),
    Backbone              = require('backbone'),
    CoursAvenueDispatcher = require('../dispatcher/CoursAvenueDispatcher'),
    CoursAvenueConstants  = require('../constants/CoursAvenueConstants'),
    ActionTypes           = CoursAvenueConstants.ActionTypes;

var LocationStore = Backbone.Collection.extend({
    model: Backbone.Model.extend({}),

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CoursAvenueDispatcher.register(this.dispatchCallback);
        this.set({ fullscreen: false });
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.BOOTSTRAP_LOCATIONS:
                this.reset(payload.data);
                break;
            case ActionTypes.HIGHLIGHT_LOCATION:
                this.map(function(level) {
                    level.set({ highlighted: false }, { silent: true });
                });
                var model = this.findWhere({ id: payload.data })
                if (model) { model.set({ highlighted: true }); }
                break;
            case ActionTypes.UNHIGHLIGHT_LOCATION:
                var model = this.findWhere({ id: payload.data })
                if (model) { model.set({ highlighted: false }); }
                break;
        }
    },

});

// the Store is an instantiated Collection; a singleton.
module.exports = new LocationStore();
