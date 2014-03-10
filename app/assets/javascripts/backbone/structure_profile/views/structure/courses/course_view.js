
StructureProfile.module('Views.Structure.Courses', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.CourseView = Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'course_view',
        itemView: Module.Plannings.PlanningView,
        itemViewContainer: 'tbody',
        emptyView: Module.EmptyView,

        itemViewOptions: function itemViewOptions (model, index) {

            return {
                collection: new Backbone.Collection(model.get("plannings"))
            };
        },

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
