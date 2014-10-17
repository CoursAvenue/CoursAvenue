
StructureProfileDiscoveryPass.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = StructureProfile.Views.Structure.Courses.Plannings.PlanningView.extend({
        template: Module.templateDirname() + 'planning_view',
        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave',
            'click [data-behavior=register]': 'showRegistrationForm'
        },

        showRegistrationForm: function showRegistrationForm (argument) {
            this.trigger('register', this.model.toJSON());
        }
    });

}, undefined);
