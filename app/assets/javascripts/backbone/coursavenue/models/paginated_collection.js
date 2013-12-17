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
                } else if (_.isArray(value)) {
                    options[key] = value;
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
        /* This method is called by the collection for a relation on the model,
        * when fetching that relation if params are required. For example,
        *
        * Structure has many courses. If we filter Structures, and then want courses,
        * we will want to filter courses in the same manner. The CoursesCollection will
        * call getQuery on its `this.structure.collection` reference. */
        getQuery: function(options) {
            var self = this;
            var params = _.extend(_.clone(this.server_api), options);

            // some of the server_api params might be functions, in which case execute them
            return _.reduce(_.pairs(params), function (memo, pair) {
                var key = pair[0];
                var value = pair[1];
                if (_.isFunction(value)) {
                    value = value.call(self);
                }

                // Decode value before encoding it if the value is not decoded when coming here
                // ANDRE removed the encode(decode()) stuff because it seems to work normally without

                // When value is an array, should be splitted as following:
                // ...&level_ids[]=1&level_ids[]=2
                if (_.isArray(value)) {
                    var new_keys = '';
                    _.each(value, function(array_value) {
                        new_keys += key + '=' + array_value + '&';
                    });
                    return memo + new_keys;
                } else {
                    return memo + key + '=' + value + '&';
                }
            }, "?").slice(0, -1); // damn trailing character!
        },

        makeOptionsFromSearch: function (search) {
            if (search.length < 1) { return {} };

            var data = search.substring(1).split("&"); // assume no values have & in them

            return _.reduce(data, function (memo, datum) {
                var pair = datum.split('='); // assume there are no equal signs in the value
                // If the key (memo[pair[0]]) already exists, then it's an array.
                // Example: &level_ids[]=1&level_ids[]=2
                if (pair[0].indexOf('[]') !== -1 || memo[pair[0]]) {
                    var array = [memo[pair[0]], pair[1]]
                    // We flatten the array in case the last memo was an array
                    memo[pair[0]] = _.flatten(_.compact(array));
                } else {
                    memo[pair[0]] = pair[1];
                }
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
