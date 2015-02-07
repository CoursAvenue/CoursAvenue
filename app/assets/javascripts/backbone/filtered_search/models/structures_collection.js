
FilteredSearch.module('Models', function(Module, App, Backbone, Marionette, $, _) {

    Module.StructuresCollection = CoursAvenue.Models.PaginatedCollection.extend({
        model: CoursAvenue.Models.Structure,

        state: {
            firstPage:   1,
            perPage:     18,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        /* even if we are bootstrapping, we still want to know the total
         * number of pages and the grandTotal, for display purposes
         * also, we need to grab the location.search and parse it, so
         * that our searches are configured correctly */
        initialize: function initialize (models, options) {
            var self = this;
            // define the server API based on the load-time URI
            this.queryParams = this.makeOptionsFromSearch(window.location.search);
            if (options.queryParams) {
                _.extend(this.queryParams, options.queryParams);
            }
            this.state.currentPage = this.queryParams.page || 1; // we always start from page 1
            //this.queryParams.page = function () { return self.currentPage; };

            // TODO: Check this
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

            // now write back the queryParams so that the search bar is up to date
            // we are passing this.queryParams for fun! ^o^ why not?
            if (window.history.pushState) { window.history.pushState({}, "Recherche", this.getQuery()); }

            if (options) {
                /* if we receive a pair from the bootstrap */
                if (options.latlng) {
                    this.queryParams.lat = options.latlng[0];
                    this.queryParams.lng = options.latlng[1];
                }

                /* TODO the results total seems to be out of sync with what we actually
                 * receive, so for now we will just do this: */
                this.state.grandTotal  = (models.length === 0) ? 0 : options.total;
                this.state.totalPages  = Math.ceil(this.state.grandTotal / this.state.perPage);
            }

            // this.url.basename             = window.location.origin;
            // window.location.origin returns "http://www.coursavenue.dev/"
            // this.url.basename             = window.location.protocol + '//' + window.location.host
            // window.location.protocol returns "http:"
            // window.location.host returns "www.coursavenue.dev/"
        },

        url: function url () {
            return (window.location.pathname || Routes.structures_path());
        },

        parse: function parse (response) {
            // we did some kind of request, I guess we should update the query
            if (window.history.pushState) { window.history.pushState({}, document.title, this.getQuery()); }

            this.state.grandTotal = response.meta.total;
            this.state.totalPages = Math.ceil(response.meta.total / this.state.perPage);

            return response.structures;
        },


        /* return an object with lat, lng, and a bounding box parsed from queryParams */
        /* the outside world must never know that we store the bounds as CSV... */
        getLatLngBounds: function getLatLngBounds () {
            var sw_latlng, ne_latlng;

            if (this.queryParams.bbox_sw && this.queryParams.bbox_ne) {
                sw_latlng = this.queryParams.bbox_sw;
                ne_latlng = this.queryParams.bbox_ne;

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
                lat: this.queryParams.lat,
                lng: this.queryParams.lng,
                bbox: {
                    sw: sw_latlng,
                    ne: ne_latlng
                }
            };
        }
    });
});

