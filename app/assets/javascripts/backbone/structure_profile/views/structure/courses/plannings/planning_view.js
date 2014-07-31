
StructureProfile.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        tagName: 'tr',
        template: Module.templateDirname() + 'planning_view',

        onRender: function onRender () {
            this.$('[data-toggle=popover]').popover();
            this.$('[data-toggle=tooltip]').tooltip();
        },

        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave'
        },

        announceEnter: function (e) {
            $(e.currentTarget).addClass("active");
            this.trigger("mouseenter", { place_id: this.model.get("place_id") });
        },

        announceLeave: function (e) {
            $(e.currentTarget).removeClass("active");
            this.trigger("mouseleave", { place_id: this.model.get("place_id") });
        }
    });

}, undefined);
