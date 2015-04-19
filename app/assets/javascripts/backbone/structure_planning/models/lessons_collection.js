/* just a basic backbone model */
StructurePlanning.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.LessonsCollection = StructureProfile.Models.LessonsCollection.extend({
        model: Backbone.Model.extend(),

        url: function url () {
            var route_details = {
                    format: 'json',
                    structure_id: this.structure_id,
                    course_type: 'lessons'
                };
            return Routes.courses_path(route_details);
        }
    });
});
