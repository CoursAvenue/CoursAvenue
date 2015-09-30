Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.SectionsCollection = Backbone.Collection.extend({
        model: Module.Section,

        url: function url () {
            var id = window.coursavenue.bootstrap.id;
            return Routes.admin_emailing_sections_path(id);
        },

        parse: function parse (data) {
            return data;
        }
    });
});
