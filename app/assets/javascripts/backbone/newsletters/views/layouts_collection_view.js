Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
  Module.LayoutsCollectionView = Backbone.Marionette.CompositeView.extend({
    template: Module.templateDirname() + 'layouts_collection_layout',
    tagName: 'div',
    // className: '',
    childViewContainer: '[data-type=layout]',
    childView: Module.LayoutView,
  });
})
