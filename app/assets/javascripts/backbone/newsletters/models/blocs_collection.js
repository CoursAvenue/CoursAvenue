Newsletter.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.BlocsCollection = Backbone.Collection.extend({
        model: Module.Bloc,
    });
});
