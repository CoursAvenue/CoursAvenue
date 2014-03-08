StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug
});

StructureProfile.addInitializer(function(options) {
    var bootstrap, places, places_view, layout, maps_view, $loader;
    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    places = new StructureProfile.Models.PlacesCollection(bootstrap.models);
    /* set up the layouts */
    layout = new StructureProfile.Views.StructureProfileLayout({collection: places});

    google_maps_view = new StructureProfile.Views.Map.GoogleMap.GoogleMapsView({
        collection: places,
        infoBoxViewOptions: {
            infoBoxClearance: new google.maps.Size(0, 0)
        }
    });

    StructureProfile.mainRegion.show(layout);
    layout.master.show(google_maps_view);

});

$(document).ready(function() {
    /* we only want the StructureProfile on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
