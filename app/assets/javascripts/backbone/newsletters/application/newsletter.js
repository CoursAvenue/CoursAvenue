// TODO: Update the names of the inputs to match the names the rails contoller
// is wating for.
var Newsletter = new Backbone.Marionette.Application({ slug: 'newsletters' });

Newsletter.addRegions({
    mainRegion: '#newsletter'
});

Newsletter.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap;

    var layouts_collection = new Newsletter.Models.LayoutsCollection(bootstrap.models.layouts);
    var newsletter = new Newsletter.Models.Newsletter(bootstrap.models.newsletter);
    var bloc_collection = new Newsletter.Models.BlocsCollection(newsletter.get('blocs'))

    var edition_view = new Newsletter.Views.EditionView({
        model: newsletter,
        collection: bloc_collection
    });

    var layouts_collection_view = new Newsletter.Views.LayoutsCollectionView({
        collection: layouts_collection
    });

    var layout = new Newsletter.Views.NewsletterLayout();

    Newsletter.mainRegion.show(layout);

    layout.showWidget(edition_view, {
        events: {
            'layout:selected': 'updateLayout'
        }
    });
    // layout.showWidget(layouts_collection_view);
});

$(document).ready(function() {
    if (Newsletter.detectRoot()) {
        Newsletter.start({});
    }
});
