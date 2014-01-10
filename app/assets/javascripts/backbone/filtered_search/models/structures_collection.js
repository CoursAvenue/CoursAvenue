
FilteredSearch.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.StructuresCollection = CoursAvenue.Models.PaginatedCollection.extend({
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

            // now write back the server_api so that the search bar is up to date
            // we are passing this.server_api for fun! ^o^ why not?
            if (window.history.pushState) { window.history.pushState({}, "Search Results", this.getQuery()); }

            this.paginator_ui.currentPage = this.server_api.page();

            if (options) {
                /* if we receive a pair from the bootstrap */
                if (options.latlng) {
                    this.server_api.lat = options.latlng[0];
                    this.server_api.lng = options.latlng[1];
                }

                /* TODO the results total seems to be out of sync with what we actually
                 * receive, so for now we will just do this: */
                this.paginator_ui.grandTotal  = (models.length === 0) ? 0 : options.total;
                this.paginator_ui.totalPages  = Math.ceil(this.paginator_ui.grandTotal / this.paginator_ui.perPage);
            }

            // this.url.basename             = window.location.origin;
            // window.location.origin returns "http://www.coursavenue.dev/"
            this.url.basename             = window.location.protocol + '//' + window.location.host
            // window.location.protocol returns "http:"
            // window.location.host returns "www.coursavenue.dev/"
        },

        /* where we can expect to find the resource we seek
         *  TODO this needs to be set on the server side */
        url: {
            resource: '/etablissements',
            data_type: '.json'
        },

        parse: function(response) {
            // we did some kind of request, I guess we should update the query
            if (window.history.pushState) { window.history.pushState({}, document.title, this.getQuery()); }

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

        /* return an object with lat, lng, and a bounding box parsed from server_api */
        /* the outside world must never know that we store the bounds as CSV... */
        getLatLngBounds: function () {
            var sw_latlng, ne_latlng;

            if (this.server_api.bbox_sw && this.server_api.bbox_ne) {
                sw_latlng = this.server_api.bbox_sw;
                ne_latlng = this.server_api.bbox_ne;

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

