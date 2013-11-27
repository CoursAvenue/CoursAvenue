
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.StructuresCollection = CoursAvenue.Lib.Models.PaginatedCollection.extend({
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

            /* we need to reset the collection on 'sync', rather than in the
             * paginated_collection_view. This is because we don't want a momentary
             * flash of the zero result set.
            *  However, the 'sync' event occurs too often, so we have to be sure
            *  that we are responding to both a sync and a filter, rather than
            *  just a sync */
            /* for now we will "detect" filters by the page being 1 */
            this.on('sync', function(model, response, xhr){
                if (model.currentPage === 1) {
                    this.reset(response.structures);
                }
            });

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

        /* where we can expect to find the resource we seek
         *  TODO this needs to be set on the server side */
        url: {
            // basename: 'http://coursavenue.dev',
            // basename: 'http://localhost:3000',
            resource: '/etablissements',
            data_type: '.json'
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

