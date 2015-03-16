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

    var router = new Newsletter.Router.NewsletterRouter();

    var layout = new Newsletter.Views.NewsletterLayout({
        router: router,
        model: newsletter
    });

    Newsletter.mainRegion.show(layout);

    layout.showWidget(edition_view, {
        events: {
            'layout:selected': 'updateLayout'
        }
    });
    // layout.showWidget(layouts_collection_view);

    Backbone.history.start({
        pushState: true,
        root: Routes.pro_structure_newsletters_path(bootstrap.structure)
    })
});

$(document).ready(function() {
    if (Newsletter.detectRoot()) {
        Newsletter.start({});
    }
});
