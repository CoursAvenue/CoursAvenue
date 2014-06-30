
StructureProfile.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        itemView: Module.TrainingView,
        template: Module.templateDirname() + 'trainings_collection_view',

        collectionReset: function collectionReset () {
            this.trigger('trainings:collection:reset', this.serializeData());
        },

        onRender: function onRender () {
            if (this.collection.length == 0) {
                this.$('[data-empty-trainings]').show();
            } else {
                this.$('[data-empty-trainings]').hide();
            }
        }

    });
});
