/* just a basic backbone model */
StructurePlanning.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.TrainingsCollection = StructureProfile.Models.TrainingsCollection.extend({
        model: Backbone.Model.extend(),

        url: function url () {
            var route_details = {
                    format: 'json',
                    structure_id: this.structure_id,
                    course_type: 'trainings'
                };
            return Routes.structure_website_courses_path(route_details);
        }
    });
});
