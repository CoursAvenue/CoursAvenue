Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Bridge = Backbone.Model.extend({
        initialize: function initialize () {
            this.on('change', this.modelChanged );
        },

        modelChanged: function modelChanged () {
            this.save();
        },

        url: function url () {
            var emailing_id = window.coursavenue.bootstrap.id;
            return Routes.admin_emailing_bridge_path(emailing_id, this.get('id'));
        }
    });
});
