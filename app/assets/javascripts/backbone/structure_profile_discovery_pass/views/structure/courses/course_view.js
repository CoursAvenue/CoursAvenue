
StructureProfileDiscoveryPass.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = StructureProfile.Views.Structure.Courses.CourseView.extend({
        template: Module.templateDirname() + 'course_view',
        itemView: Module.Plannings.PlanningView,

        events: {
            "click [data-behavior=register-to-course]": 'registerToCourse'
        },

        onItemviewRegister: function onItemviewRegister (view, data) {
            this.trigger("register", data);
        },

        registerToCourse: function registerToCourse (view, data) {
            this.trigger("register", { course_id: this.model.get('id') });
        },

    });

}, undefined);
