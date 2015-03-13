/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        validation: {
            body: {
                required: true,
                msg: 'Doit être rempli'
            },
            'user.phone_number': {
                maxLength: 20,
                msg: 'Mauvais format'
            }
        },

        initialize: function initialize () {
            if ($.cookie('last_sent_message')) {
                // De serialize the previously serialized sent message if it exists
                this.set(JSON.parse($.cookie('last_sent_message')));
            } else {
                var prefilled_body = $.cookie('participation_request_body') || 'Bonjour,\n\n' +
                                     "Je serais intéressé par vos cours. Pouvez-vous me détailler votre planning et m'envoyer toute information utile (prix d'une séance d'essai, tenue exigée, etc.) ?" +
                                     'Merci et à très bientôt !';
                this.set('body', prefilled_body);

            }
            if (CoursAvenue.currentUser()) {
                this.set('user', CoursAvenue.currentUser().toJSON());
            }
        },

        url: function url () {
            return Routes.structure_messages_path({ structure_id: this.get('structure').get('id') });
        }
    });
});
