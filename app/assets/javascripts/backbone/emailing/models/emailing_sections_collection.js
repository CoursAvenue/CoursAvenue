
/* just a basic backbone model */
Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSectionsCollection = Backbone.Collection.extend({
        model: Module.EmailingSection,
        url: function () {
            return 'bob.json'
        },

        /* if fetch returns an object, rather than an array,
        * you will process that object here */
        parse: function (data) {
            return data;
        }

        // your implementation here

    });
});

