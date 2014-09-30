Emailing.module('Views.EmailingSectionsCollection', function(Module, App, Backbone, Marionette, $, _) {

    Module.EmailingSectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'emailing_section_view',
        tagName: 'div',
        className: 'emailing-section',
        itemViewContainer: '[data-type=container]',
        attributes: {
            'data-behavior': 'emailing-section'
        },
        initialize: function initialize () {
            new Module.EmailingSectionBridgesCollectionView(this.model.get('bridges'));
            debugger
        },

        // render: 

    });
});
