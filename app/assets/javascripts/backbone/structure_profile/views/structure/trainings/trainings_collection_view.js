
StructureProfile.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        itemView: Module.TrainingView,
        template: Module.templateDirname() + 'trainings_collection_view'
    });
});
