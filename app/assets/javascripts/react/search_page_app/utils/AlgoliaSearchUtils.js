var _                   = require('underscore'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    card_index          = client.initIndex('IndexableCard_' + ENV.SERVER_ENVIRONMENT),
    subject_index       = client.initIndex('Subject_' + ENV.SERVER_ENVIRONMENT);

var card_search_state = {
      facets     : ['subjects'],
      distinct   : 1,
      hitsPerPage: 100,
      aroundRadius: 10000 // 10km
};

var card_search_helper     = algoliasearchHelper(client, 'IndexableCard_' + ENV.SERVER_ENVIRONMENT);
module.exports = {
    card_search_helper:     card_search_helper,

    searchPlannings: function searchPlannings (data) {
        data = data || {};
        planning_search_helper.clearRefinements();
        // Serialize boundingBox as Algolia wants
        if (data.insideBoundingBox) {
            planning_search_state.insideBoundingBox = data.insideBoundingBox.toString();
            delete data.insideBoundingBox;
        }
        if (data.aroundLatLng) { planning_search_state.aroundLatLng = data.aroundLatLng; }
        planning_search_helper.setState(planning_search_state);
        planning_search_helper.addRefine('subjects', data.subject);
        return planning_search_helper.search();
    },

    /*
     * @params data { depth: 0 }
     */
    searchSubjects: function searchSubjects (data) {
        data = data || {};
        return subject_index.search('', {
            hitsPerPage: 100,
            facets: this.toFacets(data),
            facetFilters: this.toFacetFilters(data)
        });
    },

    searchCards: function searchCards (data) {
        data = data || {};
        card_search_helper.clearRefinements();

        if (data.insideBoundingBox) {
            card_search_state.insideBoundingBox = data.insideBoundingBox.toString();
            delete data.insideBoundingBox;
        }

        if (data.aroundLatLng) {
            card_search_state.aroundLatLng = data.aroundLatLng;
        }

        card_search_helper.setState(card_search_state);
        if (data.subjects) {
            card_search_helper.addRefine('subjects', data.subject);
        }

        return card_search_helper.search();
    },

    // Transforming data into facet filters ie:
    // ['depth:0']
    toFacetFilters: function toFacetFilters (data) {
        return _.map(data, function(value, key) {
            return (value ? key + ':' + value : '');
        });
    },

    // Transforming data into facets
    // return * if there is no data
    toFacets: function toFacets (data) {
        facets = _.map(data, function(value, key) {
            return key;
        });
        return (facets.length > 0 ? facets.join(',') : '*')
    }
}
