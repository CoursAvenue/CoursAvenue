
OpenDoorsSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.CoursesCollection = FilteredSearch.Models.CoursesCollection.extend({
        resource: "/" + App.resource + "/"
    });
});
