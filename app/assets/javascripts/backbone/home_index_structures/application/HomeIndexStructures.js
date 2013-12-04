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
    structures      = new HomeIndexStructures.Models.TopStructuresCollection();
    structures_view = new HomeIndexStructures.Views.TopStructuresCollection.TopStructuresCollectionView({
        collection: structures,
        events: {
            'pagination:next':     'nextPage',
            'pagination:prev':     'prevPage',
            'pagination:page':     'goToPage',
            'filter:summary':      'filterQuery',
            'map:bounds':          'filterQuery',
            'filter:subject':      'filterQuery',
            'filter:search_term':  'filterQuery',
            'filter:location':     'filterQuery',
            'map:marker:focus':    'findItemView',
            'structures:updated':  'renderSlideshows'
        }
    });

    structures.fetch();
    window.pfaff = structures;

    /* set up the layouts */
    layout = new HomeIndexStructures.Views.SearchWidgetsLayout();

    layout.on('paginator:updating', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideDown();
    })
    layout.on('structures:updated', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideUp();
    })

    /* these won't be known yet because we are fetching */
    var bounds       = structures.getLatLngBounds();
    google_maps_view = new HomeIndexStructures.Views.Map.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        }
    });

    var FiltersModule = HomeIndexStructures.Views.StructuresCollection.Filters;

    HomeIndexStructures.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'paginator:updating':               'hideInfoWindow retireMarkers',
            'structures:itemview:highlighted':   'exciteMarkers',
            'structures:itemview:unhighlighted': 'exciteMarkers',
            'filter:update:map':                 'centerMap',
            'structures:itemview:found':         'showInfoWindow',
            'structures:itemview:peacock':       'togglePeacockingMarkers'
        }
    });

    layout.results.show(structures_view);
});

$(document).ready(function() {
    /* we are kind of "inheriting" this app from Filteredsearch
    *  in the sense that we will use most of the same models etc */
    _.each(FilteredSearch.submodules, function (module) {
        HomeIndexStructures[module.moduleName] = _.extend(HomeIndexStructures[module.moduleName], FilteredSearch[module.moduleName]);
    });

    /* we only want the filteredsearch on the search page */
    if (HomeIndexStructures.detectRoot()) {
        HomeIndexStructures.start({});
    }
});
