// Create a marionette app in the global namespace

var _trigger = Marionette.View.prototype.trigger;

/* event locking for our evented Marionette party party */
_.extend(Marionette.View.prototype, {
    _locks: {},
    _once_locks: {},

    trigger: function () {
        var args = Array.prototype.slice.call(arguments);

        return this.tryTrigger(args);
    },

    /* used internally, this method will unset a once lock */
    tryTrigger: function (args) {
        var message = args[0];

        if (! this.isLocked(message)) {
            _trigger.apply(this, args);
        } else {
            this.unlockOnce(message);
        }

        return this;
    },

    lock: function (message) {
        this._locks[message] = true;
    },

    unlock: function (message) {
        this._locks[message] = false;
    },

    lockOnce: function (message) {
        if (this._once_locks[message] === undefined) {
            this._once_locks[message] = { count: 0 };
        }

        this._once_locks[message].count += 1;
    },

    unlockOnce: function (message) {
        if (this.isLockedOnce(message)) {
            this._once_locks[message].count -= 1;
        }
    },

    isLocked: function (message) {
        return this._locks[message] || this.isLockedOnce(message);
    },

    isLockedOnce: function (message) {
        return this._once_locks[message] && this._once_locks[message].count > 0;
    }
});

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
    structures_view = new FilteredSearch.Views.PaginatedCollectionView({
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

    layout.on('structures:updating', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideDown();
    })
    layout.on('structures:updated', function(){
        $loader = $loader || $('[data-type="loader"]');
        $loader.slideUp();
    })

    var bounds       = structures.getLatLngBounds();
    google_maps_view = new FilteredSearch.Views.GoogleMapsView({
        collection: structures,
        mapOptions: {
            center: new google.maps.LatLng(bounds.lat, bounds.lng)
        }
    });

    /* TODO: this is lame but it doesn't seem to be possible to show 1 view in 2 places */
    top_pagination            = new FilteredSearch.Views.PaginationToolView({});
    bottom_pagination         = new FilteredSearch.Views.PaginationToolView({});
    results_summary           = new FilteredSearch.Views.ResultsSummaryView({});
    subject_filter            = new FilteredSearch.Views.SubjectFilterView({});
    categorical_filter        = new FilteredSearch.Views.CategoricalFilterView({});
    location_filter           = new FilteredSearch.Views.LocationFilterView({});

    FilteredSearch.mainRegion.show(layout);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        events: {
            'structures:updating':               'hideInfoWindow',
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
    layout.showWidget(subject_filter);
    layout.showWidget(results_summary);
    layout.showWidget(top_pagination, {
        events: {
            'structures:updated:pagination': 'reset'

        },
        selector: '[data-type=top-pagination]'
    });
    layout.showWidget(bottom_pagination, {
        events: {
            'structures:updated:pagination': 'reset'

        },
        selector: '[data-type=bottom-pagination]'
    });

    layout.results.show(structures_view);
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
