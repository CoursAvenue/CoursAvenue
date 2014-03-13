
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'course_view',
        itemView: Module.Plannings.PlanningView,
        itemViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView,

        onItemviewMouseenter: function (view, data) {
            this.trigger("mouseenter", data);
        },

        onItemviewMouseleave: function (view, data) {
            this.trigger("mouseleave", data);
        }
    });

}, undefined);
