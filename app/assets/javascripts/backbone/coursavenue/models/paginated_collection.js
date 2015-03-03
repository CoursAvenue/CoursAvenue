/* Sets up the details specific to coursavenue's API */
/* TODO I think it should preload the next and previous pages */


CoursAvenue.module('Models', function(Models, App, Backbone, Marionette, $, _) {
    Models.PaginatedCollection = Backbone.PageableCollection.extend({

        initialize: function initialize () {
            this.queryParams = {};
        },

        state: {
            firstPage:   1,
            perPage:     15,
            totalPages:  0,
            grandTotal:  0,
            radius:      2 // determines the behaviour of the ellipsis
        },

        isLastPage: function isLastPage () {
            return (this.state.currentPage == this.state.totalPages);
        },

        isFirstPage: function isFirstPage () {
            return (this.state.firstPage == this.state.currentPage);
        },

        currentQuery: function currentQuery () {
            return this.pageQuery(this.state.currentPage);
        },

        pageQuery: function pageQuery (page) {
            return this.url() + this.getQuery({ 'page': page });
        },

        setQuery: function setQuery (options) {
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
                this.unsetQuery(['bbox_ne[]', 'bbox_sw[]']);
            }
            _.extend(this.queryParams, options);
        },

        /* remove the given keys from the query */
        unsetQuery: function unsetQuery (keys) {
            this.queryParams = _.omit(this.queryParams, keys);
        },

        /* get URI query string from the queryParams values merged with opts */
        /* This method is called by the collection for a relation on the model,
        * when fetching that relation if params are required. For example,
        *
        * Structure has many courses. If we filter Structures, and then want courses,
        * we will want to filter courses in the same manner. The CoursesCollection will
        * call getQuery on its `this.structure.collection` reference. */
        getQuery: function getQuery (options) {
            var self = this;
            var params = _.extend(_.clone(this.queryParams || {}), options);

            // some of the queryParams params might be functions, in which case execute them
            return _.reduce(_.pairs(params), function (memo, pair) {
                var key   = pair[0];
                var value = pair[1];
                if (_.isFunction(value)) {
                    value = value.call(self);
                }

                // When value is an array, should be splitted as following:
                // ...&level_ids[]=1&level_ids[]=2
                if (_.isArray(value)) {
                    var new_keys = '';
                    _.each(value, function(array_value) {
                        new_keys += key + '=' + (array_value ? encodeURIComponent(array_value) : '') + '&';
                    });
                    return memo + new_keys;
                } else {
                    return memo + key + '=' + (value ? encodeURIComponent(value) : '') + '&';
                }
            }, "?").slice(0, -1); // damn trailing character!
        },

        makeOptionsFromSearch: function makeOptionsFromSearch (search) {
            if (search.length < 1) { return {} };

            var data = search.substring(1).split("&"); // assume no values have & in them

            return _.reduce(data, function (memo, datum) {
                var pair  = datum.split('='); // assume there are no equal signs in the value
                var key   = decodeURIComponent(pair[0]);
                var value = ( pair[1] ? decodeURIComponent(pair[1]) : '');

                // If the key (memo[pair[0]]) already exists AND it has [], then it's an array.
                // Example: &level_ids[]=1&level_ids[]=2
                if (key.indexOf('[]') !== -1 && memo[key]) {
                    var array = [memo[key], value]
                    // We flatten the array in case the last memo was an array
                    memo[key] = _.flatten(_.compact(array));
                } else {
                    memo[key] = value;
                }
                return memo;
            }, {});
        },
    });
});
