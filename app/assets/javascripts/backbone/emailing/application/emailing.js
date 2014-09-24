Emailing = new Backbone.Marionette.Application({ slug: 'emailing' });

// here was have to use Emailing rather than slug, because "this" will be window
// I think...
Emailing.addRegions({
    mainRegion: '#' + Emailing.slug
});

Emailing.addInitializer(function(options) {

    // if the generator was called with a model and view the
    // generator will also give us the following
    // otherwise its just empty

    // bootstrap data provided by the surrounding app
    // var bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    // If you used a bootstrap, pass in models and options
    // var EmailingSection                  = new Emailing.Models.EmailingSectionsCollection(bootstrap.models, bootstrap.options);
    var EmailingSection                  = new Emailing.Models.EmailingSectionsCollection();
    var emailing_sections_collection_view = new Emailing.Views.EmailingSectionsCollection.EmailingSectionsCollectionView({
        collection: EmailingSection,
        events: {
            'EmailingSection:go':     'someMethod'
        }
    });


    // call bootstrap or fetch to get things started?
    // EmailingSection.bootstrap(); // not sure if this will always be applicable
    EmailingSection.fetch();

    /* set up the layouts */
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

    layout.master.show(emailing_sections_collection_view); // shouldn't be "results" should be app specific
});

$(document).ready(function() {
    /* we only want Emailing on the correct page */
    if (Emailing.detectRoot()) {
        Emailing.start({});
    }

});
