var client         = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']);
var planning_index = client.initIndex('Planning_' + ENV.SERVER_ENVIRONMENT);

module.exports = {
    searchPlannings: function searchPlannings (data) {
        data = data || {}
        // Serialize boundingBox as Algolia wants
        if (data.insideBoundingBox) { data.insideBoundingBox = data.insideBoundingBox.toString(); }
        return planning_index.search('', data);
    }
}
