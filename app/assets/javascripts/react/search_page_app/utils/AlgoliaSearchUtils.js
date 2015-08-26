var _                   = require('lodash'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    subject_index       = client.initIndex('Subject_' + ENV.SERVER_ENVIRONMENT);

module.exports = {

    /*
     * @params data [{ depth: 0 }] Array of key value
     */
    searchAutocomplete: function searchAutocomplete (full_text_search, callback, insideBoundingBox) {
        full_text_search = full_text_search || '';
        var queries = [{
            indexName: 'Subject_' + ENV.SERVER_ENVIRONMENT,
            query: full_text_search,
            params: { hitsPerPage: 15, facets: '*', numericFilters: 'depth>0' }
        }, {
            indexName: 'IndexableCard_' + ENV.SERVER_ENVIRONMENT,
            query: full_text_search,
            params: _.extend({ hitsPerPage: 10, facets: '*'},
                             (insideBoundingBox ? { insideBoundingBox: insideBoundingBox} : { aroundLatLngViaIP: true }))
        }, {
            indexName: 'Structure_' + ENV.SERVER_ENVIRONMENT,
            query: full_text_search,
            params: _.extend({ hitsPerPage: 15, facets: '*'}, { aroundLatLngViaIP: true,
                                                                aroundPrecision: 5000,
                                                                aroundRadius: 50000, /* 50km */ })
        }];
        client.search(queries, callback);
        // return subject_index.search(full_text_search, data);
    },

    /*
     * @params data [{ depth: 0 }] Array of key value
     */
    searchSubjects: function searchSubjects (data, full_text_search) {
        full_text_search = full_text_search || '';
        return subject_index.search(full_text_search, data);
    },


    /*
     * Data: Hash like
          group_subject
          root_subject
          subject
          full_text_search
          insideBoundingBox
     */
    searchCards: function searchCards (data, successCallback, errorCallback) {
        var index;
        data = data || {};
        var card_search_state = {
            facets      : ['subjects.slug_name'],
            hitsPerPage : data.hitsPerPage || 160,
            distinct    : false,
            aroundRadius: 100000, // 100km
            aroundPrecision: data.aroundPrecision || 1250 // meters
        };

        if (!window.is_mobile && data.insideBoundingBox && !data.ids) {
            card_search_state.insideBoundingBox = data.insideBoundingBox.toString();
        }
        // Do not search on aroundLatLng if it is not inside bounding box
        if (data.aroundLatLng && !(data.aroundLatLng && !this.inBoundingBox(data.insideBoundingBox, data.aroundLatLng))) {
            card_search_state.aroundLatLng   = data.aroundLatLng;
            card_search_state.getRankingInfo = true;
        } else {

        }
        if (data.sort_by == 'proximity') {
            index = 'IndexableCard_' + ENV.SERVER_ENVIRONMENT;
        } else {
            index = 'IndexableCard_' + data.sort_by + '_' + ENV.SERVER_ENVIRONMENT;
        }
        var card_search_helper = algoliasearchHelper(client, index, card_search_state);
        card_search_helper.addRefine('active', true);

        if (data.group_subject)    {
            _.each(data.group_subject.root_slugs, function(root_subject) {
                card_search_helper.addDisjunctiveRefine('root_subject', root_subject);
            });
        }
        if (data.root_subject)     { card_search_helper.addRefine('root_subject', data.root_subject.slug); }
        if (data.subject)          { card_search_helper.addRefine('subjects.slug', data.subject.slug); }
        if (data.context)          { card_search_helper.addRefine('card_type', data.context); }
        if (!_.isUndefined(data.full_text_search)) { card_search_helper.setQuery(data.full_text_search); }
        if (data.planning_periods && data.context == 'course') {
            _.each(data.planning_periods, function(period) {
                card_search_helper.addDisjunctiveRefine('planning_periods', period)
            });
        }
        if (data.training_dates && data.context == 'training') {
            if (data.training_dates.start) {
                card_search_helper.addNumericRefinement('trainings', '>=', data.training_dates.start);
            }

            if (data.training_dates.end) {
                card_search_helper.addNumericRefinement('trainings_end_date', '<=', data.training_dates.end);
            }
        }
        if (data.audiences) {
            _.each(data.audiences, function(audience) {
                card_search_helper.addDisjunctiveRefine('audiences', audience)
            });
        }
        if (data.levels) {
            _.each(data.levels, function(level) {
                card_search_helper.addDisjunctiveRefine('levels', level)
            });
        }
        if (data.prices) {
            card_search_helper.addNumericRefinement('starting_price', '>=', data.prices[0]);
            card_search_helper.addNumericRefinement('starting_price', '<=', data.prices[1]);
        }

        if (data.ids) {
            _.each(data.ids, function(id) {
                card_search_helper.addDisjunctiveRefine('id', id);
            })
        }
        if (data.metro_lines && !data.metro_stop) {
            _.each(data.metro_lines, function(line) {
                card_search_helper.addDisjunctiveRefine('metro_lines', line);
            });
        }

        // By default, we want only upcoming courses | trainings
        // We have to divide per 1 000 because dates are in ms in JS.
        card_search_helper.addNumericRefinement('end_date', '>=', (new Date()).getTime() / 1000);

        card_search_helper.on("result",  successCallback);
        card_search_helper.on("error",  errorCallback);
        card_search_helper.setCurrentPage(data.page || 0);
        return card_search_helper.search();
    },

    // Transforming data into facet filters ie:
    // ['depth:0']
    toFacetFilters: function toFacetFilters (data) {
        return _.map(data, function(value, key) {
            return (!_.isUndefined(value) ? key + ':' + value : '');
        });
    },

    // Transforming data into facets
    // return * if there is no data
    toFacets: function toFacets (data) {
        facets = _.map(data, function(value, key) {
            return key;
        });
        return (facets.length > 0 ? facets.join(',') : '*')
    },

    // @bounding_box string that contains north_west & south_east lat_lng
    // @lat_lng string that contains lat & lng
    inBoundingBox: function inBoundingBox (bounding_box, lat_lng) {
        bounding_box   = bounding_box.split(',');
        lat_lng        = lat_lng.split(',');
        var north_west = [bounding_box[0], bounding_box[1]];
        var south_east = [bounding_box[2], bounding_box[3]];
        return (lat_lng[0] > north_west[0] && lat_lng[0] < south_east[0]
                && lat_lng[1] > north_west[1] && lat_lng[1] < south_east[1])
    }
}
