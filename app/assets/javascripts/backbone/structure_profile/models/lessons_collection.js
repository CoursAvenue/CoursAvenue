/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.LessonsCollection = Backbone.Collection.extend({
        model: Backbone.Model.extend(),
        comparator: 'type',

        initialize: function initialize(collection, bootstrap_meta) {
            this.structure_id = bootstrap_meta.structure_id;
            this.fetch({
                success: function success(courses_collection, response) {
                    courses_collection.reset(response.courses)
                }
            });
        },

        url: function url () {
            var route_details = {
                    format: 'json',
                    id: this.structure_id
                };
            return Routes.structure_courses_path(route_details, { course_type: 'lessons' });
        }
    });
});
