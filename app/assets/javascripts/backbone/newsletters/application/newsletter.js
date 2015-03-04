var Newsletter = new Backbone.Marionette.Application({ slug: 'newsletters' });

Newsletter.addRegions({
    mainRegion: '#newsletter'
});

Newsletter.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap;

    var layouts_collection = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
    var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
        collection: layouts_collection
    });

    var layout = new Newsletter.Views.NewsletterLayout();

    Newsletter.mainRegion.show(layout);
    layout.sidebar.show(layouts_collection_view);
});

$(document).ready(function() {
    if (Newsletter.detectRoot()) {
        Newsletter.start({});
    }
});
