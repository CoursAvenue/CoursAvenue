
/* just a basic backbone model */
HomeIndexStructures.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.TopStructuresCollection = Backbone.Collection.extend({
        model: Module.TopStructure,
        url: function () {
            return 'etablissement.json';
        },

        /* we will receive an object with meta and structures */
        parse: function (data) {
            return data.structures;
        }
    });
});

