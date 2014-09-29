Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSection = Backbone.Model.extend({
        initialize: function initialize () {
            var bridge_collection = new Module.EmailingSectionBridgesCollection(this.emailing_section_bridges);
        }
    });
});

