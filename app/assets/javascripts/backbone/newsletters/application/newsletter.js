Newsletter = new Backbone.Marionette.Application({ slug: 'newsletters' });

Newsletter.addRegions({
  mainRegion: '#newsletter'
});

Newsletter.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap;

    var layouts_collection = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
    var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
      collection: layouts_collection
    });

    // TODO: Create a Newsletter View, shows the layout view in one of its regions.
    Newsletter.mainRegion.show(layouts_collection_view)
    console.log('[DEBUG] Newsletter application started');
});

$(document).ready(function() {
    if (Newsletter.detectRoot()) {
        Newsletter.start({});
    }
});
