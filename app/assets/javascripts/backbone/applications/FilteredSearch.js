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

FilteredSearch.addInitializer(function(options){
    console.log("FilteredSearch->addInitializer");

    // Scrape all the json from the filtered-search-bootstrap
    /* TODO this is teh uuuugly code */
    var bootstrap = (function (self) {
        return {
            options: {
                total: self.bootstrap.total(),
            },
            models: self.bootstrap.models()
        };
    }(this));

    // Create an instance of your class and populate with the models of your entire collection
    var structures      = new FilteredSearch.Models.PaginatedCollection(bootstrap.models, bootstrap.options);
    var structures_view = new FilteredSearch.Views.PaginatedCollectionView({
        collection: structures
    });

    // Invoke the bootstrap function
    structures.bootstrap();
    structures.setUrl({
        basename: 'http://localhost:3000',
        resource: 'etablissements',
        data_type: 'json'
    })
    FilteredSearch.mainRegion.show(structures_view);

    window.pfaff = structures;
});

$(document).ready(function() {
    console.log('EVENT  document->ready');

    /* we only want the filteredsearch on the search page */
    if (FilteredSearch.detectRoot()) {
        FilteredSearch.start({});
    }

});
