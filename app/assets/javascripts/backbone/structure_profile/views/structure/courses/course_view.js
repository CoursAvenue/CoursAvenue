
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'course_view',
        className: "two-thirds",

        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave'
        },

        announceEnter: function (e) {
            $(e.target).addClass("active");
            this.trigger("course:mouseenter", { place_id: this.model.get("place_id")})
        },

        announceLeave: function (e) {
            $(e.target).removeClass("active");
            this.trigger("course:mouseleave", { place_id: this.model.get("place_id")})
        }

    });

}, undefined);
