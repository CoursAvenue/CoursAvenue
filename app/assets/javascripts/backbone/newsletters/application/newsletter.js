var Newsletter = new Backbone.Marionette.Application({ slug: 'newsletters' });

Newsletter.addRegions({
    mainRegion: '#newsletter',
});

Newsletter.addInitializer(function(options) {
    var bootstrap  = window.coursavenue.bootstrap;

    var newsletter     = new Newsletter.Models.Newsletter(bootstrap.models.newsletter);
    var navigation_bar = new Newsletter.Views.NavigationBarView({ newsletter: newsletter });

    var router = new Newsletter.Router.NewsletterRouter({
        model: newsletter
    });

    var layout = new Newsletter.Views.NewsletterLayout({
        router: router,
        newsletter: newsletter
    });

    router.saveLayout(layout);
    layout.on('navigation:previous', layout.previousStep);
    layout.on('navigation:next', layout.nextStep);
    router.on("route", function(route, params) {
        layout.trigger('section:changed', route);
    });

    Newsletter.mainRegion.show(layout);

    layout.showWidget(navigation_bar, {
        events: {
            'section:changed'   : 'updateButtonsVisibility',
            'newsletter:saved'  : 'setNewsletterID'
        }
    });

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
