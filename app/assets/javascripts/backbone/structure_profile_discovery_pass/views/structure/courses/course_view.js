
StructureProfileDiscoveryPass.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = StructureProfile.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'course_view',
        itemView: Module.Plannings.PlanningView,

        onItemviewRegister: function onItemviewRegister (view, data) {
            this.trigger("register", data);
        },

    });

}, undefined);
