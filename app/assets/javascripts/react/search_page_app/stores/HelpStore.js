var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var HelperModel = Backbone.Model.extend({
    initialize: function initialize () {
        _.bindAll(this, 'hasBeenDismissed', 'dismiss');
    },

    hasBeenDismissed: function hasBeenDismissed () {
        // Check cookie.
        return false;
    },

    dismiss: function dismiss () {
        // Add a cookie.
    },
});

var HelperCollection = Backbone.Collection.extend({
    model: HelperModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'getUnseenCards', 'dismiss');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    getUnseenCards: function getUnseenCards () {
        return _.reject(this.models, function (helper) {
            return helper.hasBeenDismissed();
        });
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
            type: 'info',
            description: 'Souhaitez vous trouvez un cours pour votre enfant ?',
            call_to_action: 'Cliquez ici',
        }
    ]
);
