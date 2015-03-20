
CoursAvenue.module('Views', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.SubjectsCollectionView = Marionette.CompositeView.extend({
        childView: Module.SubjectView,
        template: Module.templateDirname() + 'subjects_collection_view',
        childViewContainer: '[data-type=container]'
    });
});
