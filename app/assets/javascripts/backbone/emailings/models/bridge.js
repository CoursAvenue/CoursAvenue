Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bridge = Backbone.Model.extend({
        initialize: function initialize () {
            this.on('change', this.save);
        },

        url: function url () {
            var id = window.coursavenue.bootstrap.id;
            return Routes.bridge_update_pro_emailing_path(id)
        },
    });
});

