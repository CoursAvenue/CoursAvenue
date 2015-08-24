var _                   = require('lodash'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']);

module.exports = {
    searchSimilarSubject: function searchSimilarSubject(data, successCallback, errorCallback) {
        var structure_index = 'Structure_' + ENV.SERVER_ENVIRONMENT;
        var state = {
            hitsPerPage:  data.hitsPerPage || 20,
            aroundLatLng: data.aroundLatLng,
            distinct:     true,
            aroundRadius: 100000, // 100km
            facets: '*',
        };

        var card_search_helper = algoliasearchHelper(client, structure_index, state);

        // card_search_helper.addExclude('id', data.structure_id);
        card_search_helper.addExclude('slug', data.structure_slug);

        card_search_helper.on('result', successCallback);
        card_search_helper.on('error', errorCallback);

        return card_search_helper.search();
    },
};
