
StructureProfile.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsSummaryView = StructureProfile.Views.Structure.Courses.CoursesSummaryView.extend({
        template: Module.templateDirname() + 'trainings_summary_view'

    });
});
