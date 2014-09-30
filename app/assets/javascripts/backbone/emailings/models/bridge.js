Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bridge = Backbone.Model.extend({
        initialize: function initialize () {
            this.on('change', this.save);
        },
    });
});

