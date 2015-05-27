/* just a basic backbone model */
StructurePlanning.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.ParticipationRequest = StructureProfile.Models.ParticipationRequest.extend({

        validation: {
            'message.body': {
                required: true,
                msg: 'Vous devez remplir un message'
            },
            street: function street () {
                if (this.get('at_student_home') == 'true') {
                    if (_.isEmpty(this.get('street')) || _.isEmpty(this.get('zip_code')) ||
                                                         _.isEmpty(this.get('city_id'))) {
                        return 'Vous devez renseigner une adresse';
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
            date: function date () {
                if (this.get('course_type') != 'Course::Training' && _.isEmpty(this.get('date'))) {
                    return 'Vous devez sélectionner une date';
                }
            },
            'user.name': {
                required: true,
                msg: 'Vous devez renseigner votre nom.'
            },
            'user.phone_number': {
                maxLength: 20,
                required: true,
                msg: 'Vous devez renseigner un numéro de téléphone valide.'
            },
            'user.email': {
                pattern: 'email',
                msg: 'Vous devez renseigner un e-mail valide.'
            }
        },

        url: function url () {
            return Routes.structure_website_participation_requests_path({ structure_id: this.get('structure').get('id') });
        }
    });
});
