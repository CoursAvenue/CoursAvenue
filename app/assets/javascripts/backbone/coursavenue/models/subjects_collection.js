
/* link model joins Structures and Locations */
CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.SubjectsCollection = Backbone.Collection.extend({
        model: Models.Subject
    });
});
