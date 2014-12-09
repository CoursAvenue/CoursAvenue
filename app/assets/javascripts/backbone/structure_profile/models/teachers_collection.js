StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.TeachersCollection = Backbone.Collection.extend({
        model: Backbone.Model.extend(),

        initialize: function initialize(models, bootstrap_meta) {
            this.on('fetch:done', this.resetCollection.bind(this));
            this.structure_id = bootstrap_meta.structure_id;
            this.fetch({
                success: function(teachers_collection, response) {
                    teachers_collection.reset(response)
                }
            });
        },

        resetCollection: function resetCollection(response) {
            this.reset(response);
        },

        url: function url () {
            var route_details = {
                format: 'json',
                id: this.structure_id
            };
            return Routes.structure_teachers_path(route_details);
        }
    });
});


