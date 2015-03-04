Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.LayoutsCollection = Backbone.Collection.extend({
        model: Module.Layout,
    });
})
