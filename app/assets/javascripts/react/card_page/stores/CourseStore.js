var _                  = require('underscore'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants');

var CourseStore = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.POPULATE_COURSE:
                this.set(payload.data);
                break;
        }
    }
});

module.exports = new CourseStore();