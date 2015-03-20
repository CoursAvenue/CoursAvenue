
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.SubjectView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'subject_view'
    });
});
