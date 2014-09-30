Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {

    Module.BridgeView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'bridge_view',
        itemViewContainer: '[data-type=container]',
    });
});
