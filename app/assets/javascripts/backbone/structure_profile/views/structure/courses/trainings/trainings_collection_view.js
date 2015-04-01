
StructureProfile.module('Views.Structure.Courses.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        childView: Module.TrainingView,
        template: Module.templateDirname() + 'trainings_collection_view',

        collectionReset: function collectionReset () {
            this.trigger('trainings:collection:reset', this.serializeData());
            if (this.collection.length == 0) { this.$el.closest('[data-wrapper]').hide(); }
        }
    });
});
