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
            var self = this;
            // define the server API based on the load-time URI
            this.server_api = this.makeOptionsFromSearch(window.location.search);
            this.currentPage = 1; // we always start from page 1
            this.server_api.page = function () { return self.currentPage; };

            if (this.server_api.sort === undefined) {
                this.server_api.sort = 'rating_desc';
            }

            /* if we receive a pair from the bootstrap */
            if (options.latlng) {
                this.server_api.lat = options.latlng[0];
                this.server_api.lng = options.latlng[1];
            }

            // now write back the server_api so that the search bar is up to date
            // we are passing this.server_api for fun! ^o^ why not?
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.paginator_ui.currentPage = this.server_api.page();

            /* TODO the results total seems to be out of sync with what we actually
             * receive, so for now we will just do this: */
            this.paginator_ui.grandTotal  = (models.length === 0) ? 0 : options.total;
            this.paginator_ui.totalPages  = Math.ceil(this.paginator_ui.grandTotal / this.paginator_ui.perPage);
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
            // we did some kind of request, I guess we should update the query
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.grandTotal = response.meta.total;
            this.totalPages = Math.ceil(response.meta.total / this.paginator_ui.perPage);

            return _.union(response.structures, this.toJSON());
        },

        /* the Query methods are for populating anchors, they predict
        *  what the location.search bar would look like if performed
        *  a particular action */
        relevancyQuery: function () {
            return this.url.resource + this.getQuery({
                'sort': 'relevancy',
                'page': 1
            });
        },

        popularityQuery: function () {
            return this.url.resource + this.getQuery({
                'sort': 'rating_desc',
                'page': 1
            });
        },

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
            return this.url.resource + this.getQuery({ 'page': page });
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

        /* TODO currently we only ever extend the current filters, but there may
        * be cases when we need to remove keys: in this case, set them to false? */
        setQuery: function(options) {
            /* setQuery stringifies all incoming options */

            var self = this;
            _.map(options, function(value, key) {
                if (value === null) {
                    self.unsetQuery([key]);
                    delete options[key];

                } else if (_.isFunction(value.toString)) {
                    options[key] = value.toString();
                }
            });

            /* if lat/lng is in options, then we either have a new bounding box
            * or we want to invalidate the bounding box */
            if (options.lat || options.lng) {
                this.unsetQuery(['bbox_ne', 'bbox_sw']);
            }
            _.extend(this.server_api, options);
        },

        /* remove the given keys from the query */
        unsetQuery: function (keys) {
            this.server_api = _.omit(this.server_api, keys);
        },

        /* get URI query string from the server_api values merged with opts */
        getQuery: function(options) {
            var self = this;
            var params = _.extend(_.clone(this.server_api), options);

            // some of the server_api params might be functions, in which case execute them
            return _.reduce(_.pairs(params), function (memo, pair) {
                var key = pair[0];
                var value = pair[1];

                if (typeof value === 'function') {
                    value = value.call(self);
                }

                return memo + key + '=' + value + '&';
            }, "?").slice(0, -1); // damn trailing character!
        },

        /* return an object with lat, lng, and a bounding box parsed from server_api */
        /* the outside world must never know that we store the bounds as CSV... */
        getLatLngBounds: function () {
            var sw_latlng, ne_latlng;

            if (this.server_api.bbox_sw && this.server_api.bbox_ne) {
                sw_latlng = this.server_api.bbox_sw.split(',');
                ne_latlng = this.server_api.bbox_ne.split(',');

                sw_latlng = {
                    lat: parseFloat(sw_latlng[0]),
                    lng: parseFloat(sw_latlng[1])
                };

                ne_latlng = {
                    lat: parseFloat(ne_latlng[0]),
                    lng: parseFloat(ne_latlng[1])
                };
            }

            /* yup, everything is nice objects over here! */
            return {
                lat: this.server_api.lat,
                lng: this.server_api.lng,
                bbox: {
                    sw: sw_latlng,
                    ne: ne_latlng
                }
            };
        }

    });
});

