/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.ParticipationRequest = Backbone.Model.extend({
        options: {
            lessons_prefilled_body: 'Bonjour,\n\n' +
                                   "Je souhaiterais m'inscrire pour une première séance : " +
                                   "pouvez-vous m'envoyer toute information utile (tenue exigée, matériel requis, etc.) ?\n\n" +
                                   'Merci et à très bientôt !',

            trainings_prefilled_body: 'Bonjour,\n\n' +
                                   "Je souhaiterais participer à ce stage : " +
                                   "pouvez-vous m'envoyer toute information utile (tenue exigée, matériel requis, etc.) ?\n\n" +
                                   'Merci et à très bientôt !',

            privates_prefilled_body: 'Bonjour,\n\n' +
                                   "Je souhaiterais suivre une première séance : " +
                                   "pouvez-vous confirmer ma demande et m'envoyer toute information utile ?\n\n" +
                                   'Merci et à très bientôt !',
        },

        // We override the toJSON function to have all the params grouped into
        // `participation_request` when syncing to server
        toJSON: function toJSON () {
            // We omit to send structure to the server because it's useless.
            return { participation_request: _.clone( _.omit(this.attributes, 'structure') ) }
        },

        validation: {
            'message.body': {
                required: true,
                msg: 'Vous devez remplir un message'
            },
            street: function street () {
                if (this.get('at_student_home') == 'true') {
                    if (_.isEmpty(this.get('street')) || _.isEmpty(this.get('zip_code')) ||
                                                         _.isEmpty(this.get('city_id'))) {
                        return 'Vous devez rentrer une adresse';
                    }
                }
            },
            participants: function participants () {
                if (this.get('participants_attributes')) {
                    var number_of_participants;
                    number_of_participants = this.get('participants_attributes').map(function(participant_attribute) {
                        return parseInt(participant_attribute.number, 10)
                    }).reduce(function(a, b) {
                        return a + b;
                    });
                    if (number_of_participants == 0) {
                        return 'Vous devez être au moins 1 participant';
                    }
                }
            },
            course_id: function course_id () {
                if (_.isEmpty(this.get('course_id'))) {
                    return 'Vous devez sélectionner un cours';
                }
            },
            'user.phone_number': {
                maxLength: 20,
                msg: 'Mauvais format'
            }
        },

        initialize: function initialize () {
            var prefilled_body = $.cookie('participation_request_body') || this.options.lessons_prefilled_body;
            this.set('message', { body: prefilled_body } );
        },

        url: function url () {
            return Routes.structure_participation_requests_path({ structure_id: this.get('structure').get('id') });
        }
    });
});
