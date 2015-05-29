var algoliasearch  = require('algoliasearch'),
    client         = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    planning_index = client.initIndex('Planning_' + ENV.SERVER_ENVIRONMENT),
    subject_index  = client.initIndex('Subject_' + ENV.SERVER_ENVIRONMENT);

module.exports = {
    searchPlannings: function searchPlannings (data) {
        data = data || {}
        // Serialize boundingBox as Algolia wants
        // if (data.insideBoundingBox) { data.insideBoundingBox = data.insideBoundingBox.toString(); }
        return planning_index.search('', _.extend({
            hitsPerPage: 100,
            facets: this.toFacets(data),
            facetFilters: this.toFacetFilters(data),
        }, { insideBoundingBox: data.insideBoundingBox }));
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

    // Transforming data into facet filters ie:
    // ['depth:0']
    toFacetFilters: function toFacetFilters (data) {
        return _.map(data, function(value, key) {
            facets.push(key);
            return key + ':' + value;
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
