Emailing.module('Views.Sections', function(Module, App, Backbone, Marionette, $, _) {

    Module.SectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'section_view',
        tagName: 'div',
        className: 'emailing-section one-half inline-block push-half--bottom',
        childViewContainer: '[data-type=bridges]',
        childView: Module.Bridges.BridgeView,

        attributes: {
            'data-behavior': 'emailing-section'
        }
    });
});
