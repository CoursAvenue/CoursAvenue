
StructureProfile.module('Views.Structure.Courses.Lessons', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.LessonsCollectionView = StructureProfile.Views.Structure.Courses.CoursesCollectionView.extend({
        childView: Module.LessonView,
        template: Module.templateDirname() + 'lessons_collection_view',

        collectionReset: function collectionReset () {
            this.trigger('lessons:collection:reset', this.serializeData());
            if (this.collection.length == 0) { this.$('[data-empty-courses]').removeClass('hidden') }
        }
    });
});
