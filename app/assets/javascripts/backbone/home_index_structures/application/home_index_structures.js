HomeIndexStructures = new Backbone.Marionette.Application({ slug: 'home-index-structures' });

HomeIndexStructures.addRegions({
    mainRegion: '#' + this.slug
});

HomeIndexStructures.addInitializer(function(options) {

    // if the generator was called with a model and view the
    // generator will also give us the following
    // otherwise its just empty

    // Create an instance of your class and populate with the models of your entire collection
    var TopStructure                  = new HomeIndexStructures.Models.TopStructuresCollection();
    var top_structures_collection_view = new HomeIndexStructures.Views.TopStructuresCollection.TopStructuresCollectionView({
        collection: TopStructure,
        events: {
            'TopStructure:go':     'someMethod'
        }
    });

    window.pfaff = TopStructure;

    /* set up the layouts */
    var layout           = new HomeIndexStructures.Views.TopStructuresLayout();

    /* code to demonstrate initializing some submodules to be added to the layout here */
    // var SubModules = HomeIndexStructures.Views.WidgetsCollection.SubModules;

    // var submodule               = new SubModules.SubModule({});
    // var submodule_with_events   = new SubModules.SubModuleWithEvents({});
    // var submodule_with_selector = new SubModules.SubModuleWithSelector({});

    // HomeIndexStructures.mainRegion.show(layout);

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

    layout.master.show(top_structures_collection_view); // shouldn't be "results" should be app specific
});

$(document).ready(function() {
    /* we only want HomeIndexStructures on the correct page */
    if (HomeIndexStructures.detectRoot()) {
        HomeIndexStructures.start({});
    }

});
