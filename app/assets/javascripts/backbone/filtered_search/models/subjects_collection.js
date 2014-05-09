
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Subject = Backbone.Model.extend({

        url: function url () {
            return Routes.depth_2_subject_path({format: 'json', id: this.get("slug")})
        },

        parse: function parse (response, options) {
            if (this.get('slug') === 'other') {
                var children = _.map(response, function(subject) {
                    return subject.children;
                });
                return {
                    name:       this.get('name'),
                    slug:       this.get('slug'),
                    children: _.flatten(children)
                };
            } else {
                return response;
            }
        }

    });

    Module.SubjectsCollection = Backbone.Collection.extend({
        model: Module.Subject
    });
});
