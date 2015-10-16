var _                   = require('lodash'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']);

module.exports = {
    searchSimilarSubject: function searchSimilarSubject (data, successCallback, errorCallback) {
        var structure_index = 'Structure_' + ENV.SERVER_ENVIRONMENT;
        var state = {
            hitsPerPage:  data.hitsPerPage || 20,
            aroundLatLng: data.aroundLatLng,
            distinct:     true,
            aroundRadius: 100000, // 100km
            facets: ['id', 'active'],
            disjunctiveFacets: ['subjects.slug']
        };

        var card_search_helper = algoliasearchHelper(client, structure_index, state);

        card_search_helper.addFacetExclusion('id', data.structure_id);
        card_search_helper.addRefine('active', 'true');

        if (data.subjects) {
            _.each(data.subjects, function (subject) {
                card_search_helper.addDisjunctiveRefine('subjects.slug', subject.slug);
            });
        }

        card_search_helper.on('result', successCallback);
        card_search_helper.on('error', errorCallback);

        return card_search_helper.search();
    },

    searchSimilarCards: function searchSimilarCards (data, successCallback, errorCallback) {
        var structure_index = 'IndexableCard_by_popularity_desc_' + ENV.SERVER_ENVIRONMENT;
        var state = {
            hitsPerPage: data.hitsPerPage || 12,
            aroundLatLng: data.aroundLatLng,
            distinct: true,
            aroundRadius: 100000,
            facets: ['id', 'has_course'],
            disjunctiveFacets: ['subjects.slug']
        };
        var card_search_helper = algoliasearchHelper(client, structure_index, state);
        card_search_helper.addFacetRefinement('has_course', true);

        card_search_helper.addFacetExclusion('id', data.indexable_card_id);

        if (data.subjects) {
            _.each(data.subjects, function (subject) {
                card_search_helper.addDisjunctiveRefine('subjects.slug', subject);
            });
        }

        card_search_helper.on('result', successCallback);
        card_search_helper.on('error', errorCallback);

        return card_search_helper.search();
    },
};
