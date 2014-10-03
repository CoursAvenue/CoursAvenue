/* just a basic backbone model */
StructureProfileDiscoveryPass.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        validation: {
            body: {
                required: true,
                msg: 'Vous devez remplir un message'
            },
            course_id: {
                required: true,
                msg: 'Vous devez sélectionner un cours'
            },
            planning_id: {
                required: true,
                msg: 'Vous devez sélectionner un créneau'
            },
            'user.phone_number': {
                maxLength: 20,
                msg: 'Mauvais format'
            }
        },

        url: function url () {
            return Routes.structure_participation_requests_path({ structure_id: this.get('structure_id') });
        }
    });
});
