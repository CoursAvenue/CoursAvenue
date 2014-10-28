Emailing.module('Views.Sections', function(Module, App, Backbone, Marionette, $, _) {

    Module.SectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'section_view',
        tagName: 'table',
        className: 'emailing-section',
        itemViewContainer: '[data-type=bridges]',
        itemView: Module.Bridges.BridgeView,

        attributes: {
            'data-behavior': 'emailing-section'
        }
    });
});
