var _                   = require('lodash'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    structure_index     = client.initIndex('Structure_', + ENV.SERVER_ENVIRONMENT);

module.exports = {
    searchSimilarSubject: function searchSimilarSubject(data, successCallback, errorCallback) {
        // var card_search_helper = algoliasearchHelper(client, index, card_searc_state);
        //
        // card_search_helper.on('result', successCallback);
        // card_search_helper.on('error', errorCallback);
        //
        // return card_search_helper.search();
        successCallback([{
            name: 'aliou',
        }]);
    },
};
