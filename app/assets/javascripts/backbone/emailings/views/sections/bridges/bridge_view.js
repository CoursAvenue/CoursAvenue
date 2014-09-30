Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgeView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'bridge_view',

        tagName: 'td',
        attributes: {
            'colspan': '3',
            'width': '33%'
        },

        initialize: function initialize () {
        },
    });
});

