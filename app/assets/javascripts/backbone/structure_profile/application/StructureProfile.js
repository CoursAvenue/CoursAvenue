StructureProfile = new Backbone.Marionette.Application({ slug: 'structure-profile' });

StructureProfile.addRegions({
    mainRegion: '#' + StructureProfile.slug,
    mapContainer: '#google-maps-view'
});

StructureProfile.addInitializer(function(options) {
    var bootstrap      = window.coursavenue.bootstrap.structure,
        layout         = new StructureProfile.Views.StructureProfileLayout(),
        structure      = new CoursAvenue.Models.Structure(bootstrap, bootstrap.options),
        structure_view = new StructureProfile.Views.Structure.StructureView({
            model: structure,
            events: {
                'breadcrumbs:clear': 'refetchCoursesAndPlaces',
                'filter:removed'  : 'refetchCoursesAndPlaces'
            }
        }),
        google_maps_view, filter_breadcrumbs, places_collection, places_list_view;

    places_collection = structure.get('places');
    // new Backbone.Collection(window.coursavenue.bootstrap.structure.places, { model: StructureProfile.Models.Place });
    google_maps_view  = new StructureProfile.Views.Map.GoogleMapsView({
        collection: places_collection,
        infoBoxViewOptions: {
            infoBoxClearance: new google.maps.Size(0, 0)
        }
    });

    places_list_view          = new StructureProfile.Views.Structure.Places.PlacesCollectionView({
        collection: places_collection
    })

    layout.render();

    layout.showWidget(google_maps_view, {
        events: {
            "course:mouse:enter": "exciteMarkers",
            "course:mouse:leave": "exciteMarkers",
            "place:mouse:enter": "exciteMarkers",
            "place:mouse:leave": "exciteMarkers"
        }
    });

    layout.showWidget(places_list_view);

    layout.master.show(structure_view);
});

$(document).ready(function() {
    /* we only want the current app on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
