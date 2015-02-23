StructureProfile.module('Views.Structure.Courses.Lessons', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.LessonView = StructureProfile.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'lesson_view',
        childView: Module.Plannings.PlanningView,
        childViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView,

        childViewOptions: function childViewOptions (model, index) {
            return {
                course              : this.model.toJSON(),
                is_last             : (index == (this.collection.length - 1)),
                is_second           : (index == 1),
                is_hidden           : (index > 0),
                number_of_other_date: (this.collection.length - 1),
                course_id           : this.model.get('id')
            };
        }
    });

}, undefined);
