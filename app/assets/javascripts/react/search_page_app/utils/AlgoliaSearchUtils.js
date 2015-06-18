var _                   = require('underscore'),
    algoliasearch       = require('algoliasearch'),
    algoliasearchHelper = require('algoliasearch-helper'),
    client              = algoliasearch(ENV['ALGOLIA_APPLICATION_ID'], ENV['ALGOLIA_SEARCH_API_KEY']),
    card_index          = client.initIndex('IndexableCard_' + ENV.SERVER_ENVIRONMENT),
    subject_index       = client.initIndex('Subject_' + ENV.SERVER_ENVIRONMENT);

var card_search_state = {
    facets     : ['subjects.slug_name'],
    hitsPerPage: 8,
    aroundRadius: 10000 // 10km
};

var card_search_helper = algoliasearchHelper(client, 'IndexableCard_' + ENV.SERVER_ENVIRONMENT, card_search_state);
module.exports = {
    card_search_helper: card_search_helper,

    /*
     * @params data [{ depth: 0 }] Array of key value
     */
    searchSubjects: function searchSubjects (data) {
        return subject_index.search('', data);
    },


    /*
     * Data: Hash like
          group_subject
          root_subject
          subject
          full_text_search
          insideBoundingBox
     */
    searchCards: function searchCards (data) {
        data = data || {};
        card_search_helper.clearRefinements();
        var card_search_state = {}
        card_search_state.page = data.page || 1;
        if (data.insideBoundingBox) {
            card_search_state.insideBoundingBox = data.insideBoundingBox.toString();
            delete data.insideBoundingBox;
        }

        if (data.aroundLatLng) {
            card_search_state.aroundLatLng   = data.aroundLatLng;
            card_search_state.getRankingInfo = true;
        }

        if (data.group_subject)    {
            _.each(data.group_subject.root_slugs, function(root_subject) {
                card_search_helper.addDisjunctiveRefine('root_subject', root_subject)
            });
        }
        if (data.root_subject)     { card_search_helper.addRefine('root_subject', data.root_subject.slug); }
        if (data.subject)          { card_search_helper.addRefine('subjects.slug', data.subject.slug); }
        if (data.full_text_search) { card_search_helper.setQuery(data.full_text_search); }
        if (data.planning_periods) {
            _.each(data.planning_periods, function(period) {
                card_search_helper.addDisjunctiveRefine('planning_periods', period)
            });
        }
        if (data.audiences) {
            _.each(data.audiences, function(audience) {
                card_search_helper.addDisjunctiveRefine('audiences', audience)
            });
        }

        if (data.prices) {
            card_search_helper.addNumericRefinement('starting_price', '>=', data.prices[0]);
            card_search_helper.addNumericRefinement('starting_price', '<=', data.prices[1]);
        }

        card_search_helper.setState(_.extend(card_search_helper.state, card_search_state));

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
    }
}
