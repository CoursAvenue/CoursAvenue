Newsletter.module('Views', function(Module, App, Backbone, Marionette, $, _) {
  Module.LayoutsCollectionView = CoursAvenue.Views.EventLayout.extend({
    template: Module.templateDirname() + 'layouts_collection_layout',
  });
})
