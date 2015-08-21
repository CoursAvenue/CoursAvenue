var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var HelperModel = Backbone.Model.extend({
    defaults: function defaults () {
        return { dismissed: false, sign_in: false };
    },

    initialize: function initialize () {
        _.bindAll(this, 'hasBeenDismissed', 'dismiss', 'toggleDismiss');
    },

    softDismiss: function softDismiss () {
        this.dissmissed = true;
    },

    hasBeenDismissed: function hasBeenDismissed () {
        return ($.cookie(this.get('cookie_key')) == "true" || this.dissmissed);
    },

    dismiss: function dismiss () {
        $.cookie(this.get('cookie_key'), true);
    },

    toggleDismiss: function toggleDismiss () {
        if (this.hasBeenDismissed()) {
            $.removeCookie(this.get('cookie_key'));
        } else {
            this.dismiss();
        }
    }
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
            case ActionTypes.TOGGLE_DISMISS_HELP:
                this.toggleDismiss(payload.data);
                break;
            case ActionTypes.DISMISS_HELP:
                this.dismiss(payload.data);
                break;
        }
    },

    dismiss: function dismiss (helper) {
        helper.softDismiss();
    },

    toggleDismiss: function toggleDismiss (helper) {
        helper.toggleDismiss();
    },
});


var LoggedOutHelper = new HelperModel({
    // url:            '',
    title:          'Connectez-vous !',
    type:           'info',
    icon:           'sign-in fa',
    sign_in:        true,
    cookie_key:     'info-connection-after-favorites',
    description:    'En vous connectant, vos favoris seront enregistré dans votre compte.',
    call_to_action: 'Se connecter',
});

module.exports = new HelperCollection(
    [
        {
            url:            Routes.guide_path('quelle-activite-pour-mon-enfant'),
            name:           'Quelle activité pour mon enfant ?',
            title:          'C’est la rentrée ! ',
            type:           'info',
            icon:           'family',
            cookie_key:     'info-guide-quelle-activite-pour-mon-enfant',
            description:    'Trouvez une activité pour vos enfants grâce à notre guide interactif.',
            call_to_action: 'Suivez le guide',
        }
    ]
);
