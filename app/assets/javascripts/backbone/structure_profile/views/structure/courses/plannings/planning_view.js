
StructureProfile.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        tagName: 'tr',
        template: Module.templateDirname() + 'planning_view',

        events: {
            'mouseenter'                    : 'announceEnter',
            'mouseleave'                    : 'announceLeave',
            'click [data-behavior=register]': 'showRegistrationForm'
        },

        showRegistrationForm: function showRegistrationForm (argument) {
            this.trigger('register', this.model.toJSON());
        },

        announceEnter: function announceEnter (e) {
            $(e.currentTarget).addClass("active");
            if (this.model.get('home_place_id')) {
                this.trigger("mouseenter", { place_id: this.model.get("home_place_id") });
            }
            this.trigger("mouseenter", { place_id: this.model.get("place_id") });
        },

        announceLeave: function announceLeave (e) {
            $(e.currentTarget).removeClass("active");
            if (this.model.get('home_place_id')) {
                this.trigger("mouseleave", { place_id: this.model.get("home_place_id") });
            }
            this.trigger("mouseleave", { place_id: this.model.get("place_id") });
        }
    });

}, undefined);
