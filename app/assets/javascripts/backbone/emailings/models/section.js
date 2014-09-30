Emailing.module('Models', function(Module, App, Backbone, Marionette, $, _) {
    Module.Section = Backbone.Model.extend({
        initialize: function initialize () {
            var bridge_collection = new Module.BridgesCollection(this.get('emailing_section_bridges'));
            this.set('bridges', bridge_collection);
        }
    });
});

