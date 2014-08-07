/* just a basic backbone model */
StructureProfile.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Message = Backbone.Model.extend({

        // Validates the form
        validate: function validate () {
            errors = {};
            if (!this.get('body') || this.get('body').length == 0) {
                errors['body'] = true
            }
            // if (!this.get('body') || this.get('body').length == 0) {
            //     errors['body'] = true
            // }
            this.set('errors', errors);
            return errors;
        },

        url: function url () {
            // var structure_id  = this.structure.get('id'),
            //     query_params  = this.structure.get("query_params"),
            //     route_details = {
            //         format: 'json',
            //         id: structure_id
            //     };
            // _.extend(query_params, { course_types: ['lesson', 'private']})
            // return Routes.structure_courses_path(route_details, query_params);
        }
    });
});
