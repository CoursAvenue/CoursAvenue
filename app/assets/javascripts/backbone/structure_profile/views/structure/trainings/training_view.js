StructureProfile.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingView = StructureProfile.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'training_view',
        itemViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView
    });

}, undefined);
