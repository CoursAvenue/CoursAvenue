Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.SectionsCollection = Backbone.Collection.extend({
        model: Module.Section,

        url: function () {
            var id = window.coursavenue.bootstrap.id;
            return Routes.pro_sections_path(id);
        },

        parse: function (data) {
            return data;
        }

    });
});

