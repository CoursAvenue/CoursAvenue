SearchPage.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.PlanningsCollection = Backbone.Collection.extend({
        model: Module.Planning
    });
});
