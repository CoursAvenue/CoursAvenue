Emailing = new Backbone.Marionette.Application({ slug: 'emailings' });

// here was have to use Emailing rather than slug, because "this" will be window
// I think...
Emailing.addRegions({
    mainRegion: '#emailings-region'
});

Emailing.addInitializer(function(options) {

    var bootstrap = window.coursavenue.bootstrap;

    var EmailingSection                   = new Emailing.Models.EmailingSectionsCollection(bootstrap.models, bootstrap.options);
    var emailing_sections_collection_view = new Emailing.Views.EmailingSectionsCollection.EmailingSectionsCollectionView({
        collection: EmailingSection,
        events: {
            'EmailingSection:go':     'someMethod'
        }
    });


    var layout           = new Emailing.Views.EmailingSectionsLayout();

    /* code to demonstrate initializing some submodules to be added to the layout here */
    // var SubModules = Emailing.Views.WidgetsCollection.SubModules;

    // var submodule               = new SubModules.SubModule({});
    // var submodule_with_events   = new SubModules.SubModuleWithEvents({});
    // var submodule_with_selector = new SubModules.SubModuleWithSelector({});

    // Emailing.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
     * for setup */
    //layout.showWidget(submodule_with_events, {
    //    events: {
    //        'some:event':               'aMethod orTwo',
    //    }
    //});

    //layout.showWidget(submodule);

    //layout.showWidget(submodule_with_selector, {
    //    events: {
    //        'some:event':               'aMethod orTwo',
    //    },
    //    selector: '[data-type=something-weird]'
    //});

    Emailing.mainRegion.show(layout);
    layout.master.show(emailing_sections_collection_view); // shouldn't be "results" should be app specific
    debugger
});

$(document).ready(function() {
    /* we only want Emailing on the correct page */
    if (Emailing.detectRoot()) {
        Emailing.start({});
    }

});
