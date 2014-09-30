Emailing.module('Views.Sections', function(Module, App, Backbone, Marionette, $, _) {

    Module.SectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'section_view',
        tagName: 'div',
        className: 'emailing-section',
        itemViewContainer: '[data-type=bridges]',
        itemView: Module.Bridges.BridgesCollectionView,

        attributes: {
            'data-behavior': 'emailing-section'
        },
        initialize: function initialize () {
        },


    });
});
