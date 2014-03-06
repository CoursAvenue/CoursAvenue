
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.Subject = Backbone.Model.extend({
        url: function url () {

            return '/subjects/descendants.json?ids[]=' + this.get("slug");
        },

        parse: function parse (response, options) {
            var grand_children = this.parseGrandChildren(response);

            return {
                grand_children: grand_children
            };
        },

        parseGrandChildren: function parseGrandChildren (response) {
            // the response is an array of objects, each with one
            // key, which is an array of grand_children
            return _.inject(response, function (memo, child) {
                memo = _.union(memo, child[Object.keys(child)]);

                return memo;
            }, []);
        }
    });

    Module.SubjectsCollection = Backbone.Collection.extend({
        model: Module.Subject

    });
});
