StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug
});

StructureProfile.addInitializer(function(options) {
    var bootstrap, places, places_view, layout, maps_view,
    $loader, structure, structure_layout, headers_layout;

    bootstrap = window.coursavenue.bootstrap;

    /* models */
    structure = new StructureProfile.Models.Structure(bootstrap.model);
    places    = new StructureProfile.Models.PlacesCollection(bootstrap.places);

    /* layouts */
    structure_layout = new StructureProfile.Views.ExpandedStructureLayout({ model: structure });
    headers_layout   = new StructureProfile.Views.StructureHeadersLayout({ collection: places });

    google_maps_view = new StructureProfile.Views.Map.GoogleMap.GoogleMapsView({
        collection: places
    });

    StructureProfile.mainRegion.show(structure_layout);

    structure_layout.showWidget(headers_layout);

    headers_layout.showWidget(google_maps_view);

});

$(document).ready(function() {
    /* we only want the StructureProfile on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
