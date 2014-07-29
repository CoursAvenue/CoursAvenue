
StructureProfile.module('Views.Structure.Trainings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.TrainingsCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        itemView: Module.TrainingView,
        template: Module.templateDirname() + 'trainings_collection_view',

        collectionReset: function collectionReset () {
            this.trigger('trainings:collection:reset', this.serializeData());
            _.delay(this.iPhonizeCourseTitles, 500);
        },

        onRender: function onRender () {
            var new_html = this.$('[data-empty-trainings]').html().replace('__about__', _.capitalize(this.about)).replace('__about_genre__', this.about_genre);
            this.$('[data-empty-trainings]').html(new_html);
            if (this.collection.length == 0 && this.collection.total_not_filtered == 0) {
                this.$('[data-empty-trainings]').show();
            } else {
                this.$('[data-empty-trainings]').hide();
            }
        }

    });
});
