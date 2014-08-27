
StructureProfile.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        tagName: 'tr',
        template: Module.templateDirname() + 'planning_view',

        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave'
        },

        announceEnter: function (e) {
            $(e.currentTarget).addClass("active");
            if (this.model.get('home_place_id')) {
                this.trigger("mouseenter", { place_id: this.model.get("home_place_id") });
            }
            this.trigger("mouseenter", { place_id: this.model.get("place_id") });
        },

        announceLeave: function (e) {
            $(e.currentTarget).removeClass("active");
            if (this.model.get('home_place_id')) {
                this.trigger("mouseleave", { place_id: this.model.get("home_place_id") });
            }
            this.trigger("mouseleave", { place_id: this.model.get("place_id") });
        }
    });

}, undefined);
