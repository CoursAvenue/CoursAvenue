StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.TeachersCollection = Backbone.Collection.extend({
        model: Backbone.Model.extend(),
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


