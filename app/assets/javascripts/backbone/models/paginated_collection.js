/* Sets up the details specific to coursavenue's API */
/* TODO I think it should preload the next and previous pages */

/* default params for a blank search */
// ?utf8=✓&utf8=✓&name=&address_name=Paris&lat=48.8592&lng=2.3417&city=paris&sort=rating_desc&radius=5

/* searching for 'danse' */
// ?utf8=✓&name=Danse&address_name=Paris&lat=48.8592&lng=2.3417&city=paris&sort=rating_desc&radius=5

/* search for 'danse' with an address */
// ?utf8=✓&name=Danse&address_name=29+Avenue+du+14+Avril%2C+64100+Bayonne%2C+France&lat=43.5030279&lng=-1.4619936999999936&city=Bayonne&sort=rating_desc&radius=5

/* changing radius increases or decreases the number of results. */

FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({
        model: Models.Structure,

        /* even if we are bootstrapping, we still want to know the total
        * number of pages and the grandTotal, for display purposes
        * also, we need to grab the location.search and parse it, so
        * that our searches are configured correctly */
        initialize: function (models, options) {
            console.log("PaginatedCollection->initialize");

            var search = this.makeOptionsFromSearch(window.location.search);

            this.setUrl({ params: search });

            this.paginator_ui.currentPage = 1;
            this.paginator_ui.grandTotal = options.total;
            this.paginator_ui.totalPages = Math.ceil(options.total / this.paginator_ui.perPage);

            this.currentPage = 1;
            this.server_api = search;
            this.server_api.page = function () { return this.currentPage; };
        },

        makeOptionsFromSearch: function (search) {
            if (search.length < 1) return;

            var data = search.substring(1).split("&"); // assume no values have & in them

            return _.reduce(data, function (memo, datum) {
                var pair = datum.split('='); // assume there are no equal signs in the value

                memo[pair[0]] = pair[1];

                return memo;
            }, {});
        },

        paginator_ui: {
            firstPage:   1,
            perPage:     15,
            totalPages:  0,
            grandTotal: 0,
            radius: 1 // determines the behaviour of the ellipsis
        },

        parse: function(response) {
            console.log('PaginatedCollection->parse');
            this.grandTotal = response.meta.total;
            this.totalPages = Math.ceil(response.meta.total / this.paginator_ui.perPage);

            return response.structures;
        },

        /* the Query methods are for populating anchors */
        previousQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage - 1);
        },

        nextQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage + 1);
        },

        currentQuery: function() {
            return this.pageQuery(this.paginator_ui.currentPage);
        },

        pageQuery: function(page) {
            return this.url.resource + '?page=' + page;
        },

        paginator_core: {
            type: 'GET',
            dataType: 'json',
            url: function() {
                return this.url.basename + this.url.resource + this.url.data_type;
            }
        },

        /* where we can expect to find the resource we seek
         *  TODO this will need to be expanded to include all
         *    relevant filters and params */
        url: {
            basename: 'http://www.examples.com',
            resource: '/stuff',
            data_type: '.json'
        },

        /* TODO change this method to take a hash of options (a 'configuration object') */
        setUrl: function(options) {
            if (options.basename  != undefined) { this.url.basename  = options.basename; }
            if (options.resource  != undefined) { this.url.resource  = '/' + options.resource; }
            if (options.data_type != undefined) { this.url.data_type = '.' + options.data_type; }
            if (options.params != undefined) { this.url.params = options.params; }
        }
    });
});

