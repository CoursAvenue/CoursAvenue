
StructureProfileDiscoveryPass.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfileDiscoveryPass.Views.Structure.Courses.CoursesCollectionView.extend({
        template: Module.templateDirname() + 'trainings_collection_view',
        itemView: Module.TrainingView
    });

}, undefined);
