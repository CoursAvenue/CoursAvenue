Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgesCollection = Backbone.Collection.extend({
        model: Module.Bridge,

        parse: function (data) {
            return data;
        }
    });
});
