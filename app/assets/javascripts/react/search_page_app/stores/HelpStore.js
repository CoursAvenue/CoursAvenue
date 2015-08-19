var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var HelperModel = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'hasBeenDismissed', 'dismiss');
    },

    hasBeenDismissed: function hasBeenDismissed () {
        // Check cookie.
    },

    dismiss: function dismiss () {
        // Add a cookie.
    },
});

var HelperCollection = Backbone.Collection.extend({
    model: HelperModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'dismiss');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.DISMISS_HELP:
                this.dismiss(payload.data);
                break;
        }
    },

    dismiss: function dismiss (helper) {
        helper.dismiss();
    },
});

module.exports = new HelperCollection(
    [
        {
            url: Routes.guide_path('quelle-activite-pour-mon-enfant'),
            name: 'Quelle activité pour mon enfant ?',
            type: 'guide'
        }
    ]
);
