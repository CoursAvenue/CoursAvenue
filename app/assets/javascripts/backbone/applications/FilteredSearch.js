// Create a marionette app in the global namespace
FilteredSearch = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'filtered-search',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },
        suffix: function() { return self.slug + '-bootstrap'; },
        loader: function() { return self.slug + '-loader'; },
        /* returns the jQuery object where bootstrap data is */

        bootstrap: {
            $annex: function() { return $('[data-type=' + self.suffix() + ']'); },
            total: function() {
                return self.bootstrap.$annex().data('total');
            },
            latlng: function() {
                return self.bootstrap.$annex().data('latlng');
            },
            models: function() {
                return self.bootstrap.$annex().map(function() {
                    return JSON.parse($(this).text());
                }).get();
            },
        },

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

    // Scrape all the json from the filtered-search-bootstrap
    /* TODO this is teh uuuugly code */
    bootstrap = (function (self) {
        return {
            options: {
                total: self.bootstrap.total(),
                latlng: self.bootstrap.latlng()
            },
            models: self.bootstrap.models()
        };
    }(this));

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
            'summary:filter':     'filterQuery',
            'map:bounds':         'filterQuery',
            'map:marker:focus':   'zoomToStructure'
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
    top_pagination_tool    = new FilteredSearch.Views.PaginationToolView({});
    bottom_pagination_tool = new FilteredSearch.Views.PaginationToolView({});
    results_summary_tool   = new FilteredSearch.Views.ResultsSummaryView({});

    FilteredSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        'structures:updating':             'clearForUpdate showLoader',
        'structures:updated':              'hideLoader',
        'structures:updated:map':          'centerMap',
        'structures:itemview:highlighted':   'selectMarkers',
        'structures:itemview:unhighlighted': 'deselectMarkers'
    });

    layout.showWidget(results_summary_tool, {
        'structures:updated': 'resetSummaryTool'
    }, '[data-type=results-summary-tool]');

    layout.showWidget(top_pagination_tool, {
        'structures:updated': 'resetPaginationTool'
    }, '[data-type=top-pagination-tool]');

    layout.showWidget(bottom_pagination_tool, {
        'structures:updated': 'resetPaginationTool'
    }, '[data-type=bottom-pagination-tool]');

    layout.results.show(structures_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
