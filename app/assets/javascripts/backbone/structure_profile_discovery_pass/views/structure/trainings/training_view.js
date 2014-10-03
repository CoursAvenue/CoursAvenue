
StructureProfileDiscoveryPass.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingView = StructureProfileDiscoveryPass.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'training_view'
    });

}, undefined);
