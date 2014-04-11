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
                'breadcrumbs:clear': 'broadenSearch',
                'filter:removed'   : 'broadenSearch',
                'filter:popstate'  : 'narrowSearch',
                'courses:collection:reset': 'renderCourseSummary'
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
            "place:mouse:leave": "exciteMarkers",
            "places:collection:updated": "recenterMap"
        }
    });

    layout.showWidget(places_list_view);

    layout.master.show(structure_view);

    if (window.location.hash.indexOf('recommandation-') != -1) {
        $('[href=#tab-comments]').click();
        _.delay(function() {
            $.scrollTo($(window.location.hash), {duration: 500, offset: { top: $('#media-grid').height() }});
        }, 500);
    }
    if (window.location.hash.length > 0 && window.location.hash != '#_=_') {
        $('[href=' + window.location.hash + ']').click();
        _.delay(function() {
            $.scrollTo($(window.location.hash), {duration: 500, offset: { top: $('#media-grid').height() }});
        }, 500);
    }
});

$(document).ready(function() {
    /* we only want the current app on the search page */
    if (StructureProfile.detectRoot()) {
        StructureProfile.start({});
    }

});
