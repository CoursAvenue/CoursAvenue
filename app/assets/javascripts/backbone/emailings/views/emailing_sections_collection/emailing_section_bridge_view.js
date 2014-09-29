Emailing.module('Views.EmailingSectionsCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.EmailingSectionView = Backbone.Marionette.ItemView.extend({
        template: Module.templateDirname() + 'emailing_section_bridge_view',
        tagName: 'div',
        className: 'emailing-bridge-section',
        itemViewContainer: '[data-type=container]',
        attributes: {
            'data-behavior': 'emailing-bridge-section'
        }
    });
});
