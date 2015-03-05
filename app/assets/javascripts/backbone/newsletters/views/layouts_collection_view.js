Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
    Module.LayoutsCollectionView = Backbone.Marionette.CompositeView.extend({
        template: Module.templateDirname() + 'layouts_collection_layout',
        tagName: 'div',
        childViewContainer: '[data-type=layout]',
        childView: Module.LayoutView,

        // Setting this allows us to send events without a prefix in the childView
        // and to receive them with the prefix in the application.
        childViewEventPrefix: 'layout',
    });
})
