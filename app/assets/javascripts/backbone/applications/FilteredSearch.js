// Create a marionette app in the global namespace
FilteredSearch = (function (){
    var self = new Backbone.Marionette.Application({
        slug: 'filtered-search',

        /* for use in query strings */
        root:   function() { return self.slug + '-root'; },
        suffix: function() { return self.slug + '-bootstrap'; },
        /* returns the jQuery object where bootstrap data is */

        bootstrap: {
            $annex: function() { return $('[data-type=' + self.suffix() + ']'); },
            total: function() {
                return self.bootstrap.$annex().data('total');
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
            },
            models: self.bootstrap.models()
        };
    }(this));

    // Create an instance of your class and populate with the models of your entire collection
    structures      = new FilteredSearch.Models.PaginatedCollection(bootstrap.models, bootstrap.options);
    structures_view = new FilteredSearch.Views.PaginatedCollectionView({
        collection: structures,
        events: {
            'pagination:next': 'nextPage'
        }
    });

    structures.bootstrap();
    window.pfaff = structures;

    /* set up the layouts */
    layout = new FilteredSearch.Views.SearchWidgetsLayout();

    google_maps_view = new FilteredSearch.Views.GoogleMapsView({ collection: structures });
    pagination_tool_view = new FilteredSearch.Views.PaginationToolView({});

    FilteredSearch.mainRegion.show(layout);
    layout.results.show(structures_view);

    /* we can add a widget along with a callback to be used
    * for setup */
    layout.showWidget(google_maps_view, {
        'paginator:updating': 'clearForUpdate'
    });

    layout.showWidget(pagination_tool_view, {
        'paginator:updated': 'resetPaginationTool'
    });

    /* Later:
    * layout.widgets.show(pagination_tool_view);
    * layout.widgets.show(google_maps_view);
    * layout.widgets.show(filter_controls_view);
    *
    * Layout will act as the moderator of events being
    * emitted from widgets and received by the search */
});

$(document).ready(function() {
    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
