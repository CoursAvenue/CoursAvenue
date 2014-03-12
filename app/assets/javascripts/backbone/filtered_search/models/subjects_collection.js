
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Subject = Backbone.Model.extend({

        url: function url () {
            return Routes.depth_2_subject_path({format: 'json', id: this.get("slug")})
        },

        parse: function parse (response, options) {
            return {
                grand_children: response
            };
        }

    });

    Module.SubjectsCollection = Backbone.Collection.extend({
        model: Module.Subject
    });
});
