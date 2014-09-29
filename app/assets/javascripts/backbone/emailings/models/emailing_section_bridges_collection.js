Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSectionBridgesCollection = Backbone.Collection.extend({
        model: Module.EmailingSectionBridge,

        parse: function (data) {
            return data;
        }
    });
});
