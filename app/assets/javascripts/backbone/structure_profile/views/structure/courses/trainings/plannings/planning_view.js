StructureProfile.module('Views.Structure.Courses.Trainings.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = StructureProfile.Views.Structure.Courses.Plannings.PlanningView.extend({
        template: Module.templateDirname() + 'planning_view',
        tagName: 'div'
    });

}, undefined);
