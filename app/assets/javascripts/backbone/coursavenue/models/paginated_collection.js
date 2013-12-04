/* Sets up the details specific to coursavenue's API */
/* TODO I think it should preload the next and previous pages */

CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.Paginator.requestPager.extend({

        initialize: function () {
            this.server_api = {};

        },

        paginator_ui: {
            firstPage:   1,
            perPage:     15,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
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

                return memo + key + '=' + encodeURI(value) + '&';
            }, "?").slice(0, -1); // damn trailing character!
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

        paginator_core: {
            type: 'GET',
            dataType: 'json',
            url: function() {
                return this.url.basename + this.url.resource + this.url.data_type;
            }
        }

    });
});
