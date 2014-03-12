
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'course_view',
        itemView: Module.Plannings.PlanningView,
        itemViewContainer: '[data-type=plannings-container]',
        emptyView: Module.EmptyView,

        itemViewOptions: function itemViewOptions (model, index) {

            return {
                collection: new Backbone.Collection(model.get("plannings"))
            };
        },

        onItemviewMouseenter: function (view, data) {
            this.trigger("mouseenter", data);
        },

        onItemviewMouseleave: function (view, data) {
            this.trigger("mouseleave", data);
        }

    });

}, undefined);
