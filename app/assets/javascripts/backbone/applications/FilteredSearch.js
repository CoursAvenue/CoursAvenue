FilteredSearch = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'filtered-search',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },
        loader: function() { return self.slug + '-loader'; },

        /* methods for returning the relevant jQuery collections */
        $root: function() {
            return $('[data-type=' + self.root() + ']');
        },

        /* Return the element in which the application will be appended */
        $loader: function() {
            return $('[data-type=' + self.loader() + ']');
        },

        /* A filteredSearch should only start if it detects
         * an element whose data-type is the same as its
         * root property.
         * @throw the root was found to be non-unique on the page */
        detectRoot: function() {
            var result = self.$root().length;

            if (result > 1) {
                throw {
                    message: 'FilteredSearch->detectRoot: ' + self.root() + ' element should be unique'
                }
            }

            return result > 0;
        },

        /* convenience method */
        capitalize: function (word) {
            return word.charAt(0).toUpperCase() + word.slice(1);
        }
    });

    return self;
}());

FilteredSearch.addRegions({
    mainRegion: '#filtered-search'
});

FilteredSearch.addInitializer(function(options) {
    var bootstrap, structures, structures_view, layout, maps_view, $loader;

    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    structures      = new FilteredSearch.Models.PaginatedCollection(bootstrap.models, bootstrap.options);
    structures_view = new FilteredSearch.Views.FilteredSearch.PaginatedCollection.PaginatedCollectionView({
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
    layout           = new FilteredSearch.Views.FilteredSearch.SearchWidgetsLayout();

    layout.on('structures:updating', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideDown();
    })
    layout.on('structures:updated', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideUp();
    })

    var bounds       = structures.getLatLngBounds();
    google_maps_view = new FilteredSearch.Views.FilteredSearch.Map.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        }
    });

    var FiltersModule = FilteredSearch.Views.FilteredSearch.PaginatedCollection.Filters;

    /* TODO: this is lame but it doesn't seem to be possible to show 1 view in 2 places */
    infinite_scroll_button    = new FiltersModule.InfiniteScrollButtonView({});
    results_summary            = new FiltersModule.ResultsSummaryView({});
    subject_filter            = new FiltersModule.SubjectFilterView({});
    categorical_filter        = new FiltersModule.CategoricalFilterView({});
    location_filter           = new FiltersModule.LocationFilterView({});

    FilteredSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'structures:updating':               'hideInfoWindow retireMarkers',
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
    layout.showWidget(categorical_filter);
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
