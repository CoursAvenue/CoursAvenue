
StructureProfileDiscoveryPass.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfile.Views.Structure.Trainings.TrainingsCollectionView.extend({
        template: Module.templateDirname() + 'trainings_collection_view',
        itemView: Module.TrainingView
    });

}, undefined);
