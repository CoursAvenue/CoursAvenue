/* just a basic backbone model */
CoursAvenue.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollection = Backbone.Collection.extend({
        resource: "/" + App.resource + "/",

        parse: function parse (response, options) {
            return response.courses;
        },

        url: function url (models) {
            var structure_id  = this.structure.get('id'),
                query_params  = this.structure.get("query_params"),
                route_details = {
                    format: 'json',
                    id: structure_id
                };

            /* backboneRelational expects url(models) to return a URL
            *  different from just calling url() without a models params.
            *  Normally, url would build a URL including something like
            *  "&ids=1,2,3" but in our case the URL doesn't actually
            *  differ. So we are just returning an empty string to trick
            *  backbonerelational. */
            if (!structure_id && models === undefined) { return ''; }

            return Routes.structure_courses_path(route_details, query_params);
        }
    });

    Module.Structure = Backbone.Model.extend({});
});


