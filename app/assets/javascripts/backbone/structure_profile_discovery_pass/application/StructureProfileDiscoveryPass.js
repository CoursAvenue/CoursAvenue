/* StructureProfileDiscoveryPass extends StructureProfile
 *
 * This is an experiment to see if a deep copy of an app will work */

StructureProfileDiscoveryPass = StructureProfile.rebrand('structure-profile-discovery-pass', Routes.open_courses_path().replace('/', ''));

StructureProfileDiscoveryPass.addRegions({
    mainRegion: '#' + StructureProfileDiscoveryPass.slug
});

StructureProfileDiscoveryPass.addInitializer(function(options) {
    var bootstrap      = window.coursavenue.bootstrap,
        layout         = new StructureProfile.Views.StructureProfileLayout(),
        structure      = new StructureProfile.Models.Structure(bootstrap.structure, bootstrap.meta),
        structure_view = new StructureProfile.Views.Structure.StructureView({
            model: structure
        }),
        google_maps_view, sticky_google_maps_view, places_collection, places_list_view, comments_collection_view;

    places_collection = structure.get('places');
    participation_request_view = new StructureProfileDiscoveryPass.Views.ParticipationRequests.RequestFormView( { structure: structure } );
    google_maps_view  = new StructureProfile.Views.Map.GoogleMapsView({
        collection:         places_collection,
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) },
        mapOptions:         { scrollwheel: false },
        mapClass:           'google-map--medium'
    });

    sticky_google_maps_view  = new StructureProfile.Views.Map.GoogleMapsView({
        collection:         places_collection,
        sticky:             true,
        mapOptions:         { scrollwheel: false },
        infoBoxViewOptions: { infoBoxClearance: new google.maps.Size(0, 0) }
    });

    places_list_view         = new StructureProfile.Views.Structure.Places.PlacesCollectionView({ collection: places_collection });
    comments_collection_view = new StructureProfile.Views.Structure.Comments.CommentsCollectionView({
        collection: structure.get('comments'),
        about     :  structure.get('about')
    });

    layout.render();

    layout.showWidget(participation_request_view, {
        selector: '[data-type=contact-form]',
        events: {
            'planning:register' : 'showRegistrationForm'
        }
    });
    layout.showWidget(sticky_google_maps_view, {
        selector: '[data-type=sticky-map]',
        events: {
            'course:mouse:enter'       : 'exciteMarkers',
            'course:mouse:leave'       : 'unexciteMarkers',
            'place:mouse:enter'        : 'exciteMarkers',
            'place:mouse:leave'        : 'unexciteMarkers',
            'places:collection:updated': 'recenterMap',
            'map:marker:click'         : 'showInfoWindow'
        }
    });

    layout.showWidget(google_maps_view, {
        events: {
            'course:mouse:enter'       : 'exciteMarkers',
            'course:mouse:leave'       : 'unexciteMarkers',
            'place:mouse:enter'        : 'exciteMarkers',
            'place:mouse:leave'        : 'unexciteMarkers',
            'places:collection:updated': 'recenterMap',
            'map:marker:click'         : 'showInfoWindow'
        }
    });

    layout.showWidget(places_list_view);
    layout.showWidget(comments_collection_view);

    layout.master.show(structure_view);

});

$(document).ready(function() {

    if (StructureProfileDiscoveryPass.detectRoot()) {
        StructureProfileDiscoveryPass.start({});
    }
});
