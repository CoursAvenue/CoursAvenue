// Create a marionette app in the global namespace
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
    var bootstrap, structures, structures_view, layout, maps_view;

    bootstrap = window.coursavenue.bootstrap;

    // Create an instance of your class and populate with the models of your entire collection
    structures      = new FilteredSearch.Models.PaginatedCollection(bootstrap.models, bootstrap.options);
    structures_view = new FilteredSearch.Views.PaginatedCollectionView({
        collection: structures,
        events: {
            'structures:updating': 'showLoader',
            'structures:updated': 'hideLoader',
            'pagination:next':    'nextPage',
            'pagination:prev':    'prevPage',
            'pagination:page':    'goToPage',
            'filter:summary':     'filterQuery',
            'map:bounds':         'filterQuery',
            'filter:search_term': 'filterQuery',
            'filter:location':     'filterQuery',
            'map:marker:focus':    'zoomToStructure'
        }
    });

    structures.bootstrap();
    window.pfaff = structures;

    /* set up the layouts */
    layout           = new FilteredSearch.Views.SearchWidgetsLayout();

    var bounds       = structures.getLatLngBounds();
    google_maps_view = new FilteredSearch.Views.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        }
    });

    /* TODO: this is lame but it doesn't seem to be possible to show 1 view in 2 places */
    top_pagination_tool        = new FilteredSearch.Views.PaginationToolView({});
    bottom_pagination_tool     = new FilteredSearch.Views.PaginationToolView({});
    results_summary_tool       = new FilteredSearch.Views.ResultsSummaryView({});
    categorical_filter_tool    = new FilteredSearch.Views.CategoricalFilterView({});
    location_filter            = new FilteredSearch.Views.LocationFilterView({});

    FilteredSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        'structures:updating':               'clearForUpdate showLoader',
        'structures:updated':                'hideLoader',
        'structures:itemview:highlighted':   'selectMarkers',
        'structures:itemview:unhighlighted': 'deselectMarkers',
        'filter:update:map':                 'centerMap'
    });

    /* TODO these widgets all have "reset" bound to "updated"...
    *  let's make that a default: the master declares a "setup"
    *  event, and the widgets all run their "setup" method on
    *  that event. */
    /* TODO all these widgets have "dependencies", that is, they
    * can depend on the main widget for data. Let's make this
    * explicit so that the order of the 'showWidget' calls doesn't
    * matter */
    /* TODO all these widgets use 'data-type=view_name' so lets
    * make that a default. */
    /* TODO the layout is divided into two parts: one widget well,
    * where widgets can be added (the map is there), and one div
    * full of explicitly added widgets. We should either not use
    * wells, or fix the well system to adapt to different layout
    * designs easily */
    layout.showWidget(results_summary_tool, {
        'structures:updated:summary': 'resetSummaryTool'
    }, '[data-type=results-summary-tool]');

    layout.showWidget(categorical_filter_tool, {
        once: {
            'structures:updated:filters': 'resetCategoricalFilterTool',
        }
    }, '[data-type=categorical-filter-tool]');

    layout.showWidget(location_filter, {
        once: {
            'structures:updated:filters': 'setup',
        }
    });

    layout.showWidget(top_pagination_tool, {
        'structures:updated:pagination': 'resetPaginationTool'
    }, '[data-type=top-pagination-tool]');

    layout.showWidget(bottom_pagination_tool, {
        'structures:updated:pagination': 'resetPaginationTool'
    }, '[data-type=bottom-pagination-tool]');

    layout.results.show(structures_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
