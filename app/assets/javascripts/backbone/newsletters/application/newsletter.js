var Newsletter = new Backbone.Marionette.Application({ slug: 'newsletters' });

Newsletter.addRegions({
    mainRegion: '#newsletter'
});

Newsletter.addInitializer(function(options) {
    var bootstrap = window.coursavenue.bootstrap;

    var newsletter = new Newsletter.Models.Newsletter(bootstrap.models.newsletter);
    var bloc_collection = new Newsletter.Models.BlocsCollection(newsletter.get('blocs'))

    var edition_view = new Newsletter.Views.EditionView({
        model: newsletter,
        collection: bloc_collection
    });

    var router = new Newsletter.Router.NewsletterRouter({
        model: newsletter
    });

    var layout = new Newsletter.Views.NewsletterLayout({
        router: router,
    });

    router.saveLayout(layout);

    Newsletter.mainRegion.show(layout);

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
