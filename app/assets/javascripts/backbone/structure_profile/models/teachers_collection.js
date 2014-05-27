StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.TeachersCollection = Backbone.Collection.extend({
        model: Backbone.Model.extend(),

        initialize: function initialize() {
            this.on('fetch:done', this.resetCollection.bind(this));
        },

        resetCollection: function resetCollection(response) {
            this.reset(response);
        },

        url: function() {
            var structure_id  = this.structure.get('id'),
                route_details = {
                    format: 'json',
                    id: structure_id
                };
            return Routes.structure_teachers_path(route_details);
        }
    });
});


