/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.TrainingsCollection = Backbone.Collection.extend({
        model: Backbone.Model.extend(),

        initialize: function initialize() {
            this.on('fetch:done', this.resetCollection.bind(this));
        },

        resetCollection: function resetCollection(response) {
            this.reset(response.courses);
        },

        url: function() {
            var structure_id  = this.structure.get('id'),
                query_params  = this.structure.get("query_params"),
                route_details = {
                    format: 'json',
                    id: structure_id
                };
            _.extend(query_params, { course_types: ['training']})
            return Routes.structure_courses_path(route_details, query_params);
        }
    });
});
