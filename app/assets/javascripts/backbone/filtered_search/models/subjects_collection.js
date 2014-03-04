
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.SubjectsCollection = Backbone.Collection.extend({

        url: function () {
            console.log("url");
        }

    });
});
