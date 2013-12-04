FilteredSearch = new Backbone.Marionette.Application({ slug: 'filtered-search' });

FilteredSearch.addRegions({
    mainRegion: '#' + FilteredSearch.slug
});

FilteredSearch.addInitializer(function(options) {
    var bootstrap, structures, structures_view, layout, maps_view, $loader;

    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    structures      = new FilteredSearch.Models.StructuresCollection(bootstrap.models, bootstrap.options);
    structures_view = new FilteredSearch.Views.StructuresCollection.StructuresCollectionView({
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


    structures.bootstrap();
    window.pfaff = structures;

    /* set up the layouts */
    layout           = new FilteredSearch.Views.SearchWidgetsLayout();

    layout.on('paginator:updating', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideDown();
    })
    layout.on('structures:updated', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideUp();
    })

    var bounds       = structures.getLatLngBounds();
    google_maps_view = new FilteredSearch.Views.Map.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        }
    });

    var FiltersModule = FilteredSearch.Views.StructuresCollection.Filters;

    /* TODO: this is lame but it doesn't seem to be possible to show 1 view in 2 places */
    infinite_scroll_button    = new FiltersModule.InfiniteScrollButtonView({});
    results_summary           = new FiltersModule.ResultsSummaryView({});
    subject_filter            = new FiltersModule.SubjectFilterView({});
    keyword_filter            = new FiltersModule.KeywordFilterView({});
    location_filter           = new FiltersModule.LocationFilterView({});

    FilteredSearch.mainRegion.show(layout);

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

    /* TODO all these widgets have "dependencies", that is, they
     * can depend on the main widget for data. Let's make this
     * explicit so that the order of the 'showWidget' calls doesn't
     * matter */
    layout.showWidget(keyword_filter);
    layout.showWidget(location_filter);
    layout.showWidget(results_summary);
    layout.showWidget(subject_filter);
    layout.showWidget(infinite_scroll_button);

    layout.results.show(structures_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
