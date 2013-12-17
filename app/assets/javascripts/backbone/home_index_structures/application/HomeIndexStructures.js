/* HomeIndexStructures */
/* @brief: HomeIndexStructures is a small app extending from FilteredSearch.
*   it presents only the list of structures, and the google map. The structures
*   it uses as a data-source are fetched from etablissements/best.json rather
*   than from the plain etablissements controller */
HomeIndexStructures = new Backbone.Marionette.Application({ slug: 'home-index-structures' });

HomeIndexStructures.addRegions({
    mainRegion: '#' + HomeIndexStructures.slug
});

HomeIndexStructures.addInitializer(function(options) {

    var structures, structures_view, layout, maps_view, $loader;

    // Create an instance of your class and populate with the models of your entire collection
    structures      = new HomeIndexStructures.Models.StructuresCollection();
    structures_view = new HomeIndexStructures.Views.StructuresCollection.StructuresCollectionView({
        collection: structures,
        events: {
            'map:marker:focus':    'findItemView'
        }
    });

    structures.fetch({reset: true}); // Use to listen to the reset event of the structure
    window.pfaff = structures;

    /* set up the layouts */
    layout = new HomeIndexStructures.Views.StructuresLayout();

    /* these won't be known yet because we are fetching */
    var bounds       = structures.getLatLngBounds();
    google_maps_view = new HomeIndexStructures.Views.Map.GoogleMap.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        },
        mapClass: 'google-map google-map--medium'
    });

    var FiltersModule = HomeIndexStructures.Views.StructuresCollection.Filters;

    HomeIndexStructures.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'structures:itemview:highlighted':   'exciteMarkers',
            'structures:itemview:unhighlighted': 'exciteMarkers',
            'structures:itemview:found':         'showInfoWindow'
        }
    });

    layout.master.show(structures_view);
});

$(document).ready(function() {
    /* we are kind of "inheriting" this app from Filteredsearch
    *  in the sense that we will use most of the same models etc */

    /* we need a better way to do this: extend is not deep enough */

    // I think we should cherry pick the module we want to extend from.
    // Or, the modules should now override already defined ones.
    _.each(FilteredSearch.submodules, function (module) {
        // Do not extend from structures
        _.extend(HomeIndexStructures[module.moduleName],
                _.omit(FilteredSearch[module.moduleName], 'Structure', 'StructuresCollection', 'Map'));
    });


    /* we only want the filteredsearch on the search page */
    if (HomeIndexStructures.detectRoot()) {
        HomeIndexStructures.start({});
    }
});
