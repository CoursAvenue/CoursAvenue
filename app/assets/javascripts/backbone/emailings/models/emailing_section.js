Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.EmailingSection = Backbone.Model.extend({
        initialize: function initialize () {
            var bridge_collection = new Module.EmailingSectionBridgesCollection(this.get('emailing_section_bridges'));
            this.set('bridges', bridge_collection);
        }
    });
});

