Emailing.module('Views.Sections.Bridges', function(Module, App, Backbone, Marionette, $, _) {
    Module.BridgesCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'bridges_collection_view',
        itemView: Module.BridgeView,
        itemViewContainer: '[data-type=container]',

        tagName: 'td',
        attributes: {
            'colspan': '3',
            'width': '33%'
        },

        initialize: function initialize () {

        }
    });
});

