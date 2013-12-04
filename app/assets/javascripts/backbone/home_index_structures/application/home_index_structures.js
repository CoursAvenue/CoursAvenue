HomeIndexStructures = new Backbone.Marionette.Application({ slug: 'bob' });

HomeIndexStructures.addRegions({
    mainRegion: '#' + HomeIndexStructures.slug
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

    layout.master.show(top_structures_collection_view); // shouldn't be "results" should be app specific
});

$(document).ready(function() {
    /* we only want HomeIndexStructures on the correct page */
    if (HomeIndexStructures.detectRoot()) {
        HomeIndexStructures.start({});
    }

});
