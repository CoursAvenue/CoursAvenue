SearchPage.module('Views', function(Module, App, Backbone, Marionette, $, _, undefined) {

    Module.PlanningView = Marionette.ItemView.extend({
        template: Module.templateDirname() + 'planning_view',
        // childViewContainer: '[data-type=container]'
    });
});
