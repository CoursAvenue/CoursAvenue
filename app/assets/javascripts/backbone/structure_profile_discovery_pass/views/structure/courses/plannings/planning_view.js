
StructureProfileDiscoveryPass.module('Views.Structure.Courses.Plannings', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = StructureProfile.Views.Structure.Courses.Plannings.PlanningView.extend({
        template: Module.templateDirname() + 'planning_view',
        events: {
            'mouseenter': 'announceEnter',
            'mouseleave': 'announceLeave',
            'click [data-behavior=register]': 'showRegistrationForm'
        },

        showRegistrationForm: function showRegistrationForm (argument) {
            if ($.cookie('discovery_pass_danse_test')) {
                  $.fancybox($('#sign-in-to-see'), {
                          topRatio    : 0.3,
                          openSpeed   : 300,
                          maxWidth    : 830,
                          maxHeight   : 450,
                          fitToView   : false,
                          width       : 830,
                          height      : 240,
                          autoSize    : false,
                          autoResize  : false,
                          padding     : 0
                });
            } else {
                this.trigger('register', this.model.toJSON());
            }
        }
    });

}, undefined);
