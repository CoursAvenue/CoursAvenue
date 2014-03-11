StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug,
    mapContainer: '#google-maps-view'
});

StructureProfile.addInitializer(function(options) {
    var bootstrap      = window.coursavenue.bootstrap.structure,
        layout         = new StructureProfile.Views.StructureProfileLayout(),
        structure      = new FilteredSearch.Models.Structure(bootstrap, bootstrap.options),
        structure_view = new StructureProfile.Views.Structure.StructureView({ model: structure }),
        bounds         = window.coursavenue.bootstrap.center,
        google_maps_view;

    window.pfaff = structure;

    google_maps_view = new StructureProfile.Views.Map.GoogleMapsView({
        collection: new Backbone.Collection(window.coursavenue.bootstrap.structure.places, { model: StructureProfile.Models.Place }),
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        },
        infoBoxOptions: {
            infoBoxClearance: new google.maps.Size(100, 100)
        }
    });

    layout.render();
    layout.showWidget(google_maps_view, {
        events: {
            "course:mouse:enter": "exciteMarkers",
            "course:mouse:leave": "exciteMarkers"
        }
    });

    layout.master.show(structure_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
