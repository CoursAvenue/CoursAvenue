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

            this.currentPage = 1;
            // define the server API based on the load-time URI
            this.server_api = this.makeOptionsFromSearch(window.location.search);
            this.server_api.page = function () { return this.currentPage; };

            this.paginator_ui.currentPage = 1;
            this.paginator_ui.grandTotal  = options.total;
            this.paginator_ui.totalPages  = Math.ceil(options.total / this.paginator_ui.perPage);
            this.url.basename             = window.location.origin;
        },

        makeOptionsFromSearch: function (search) {
            if (search.length < 1) { return {} };

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
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
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
         *  TODO this needs to be set on the server side */
        url: {
            // basename: 'http://coursavenue.dev',
            // basename: 'http://localhost:3000',
            resource: '/etablissements',
            data_type: '.json'
        },

        setQuery: function(options) {
            _.extend(this.server_api, options);
        }
    });
});

