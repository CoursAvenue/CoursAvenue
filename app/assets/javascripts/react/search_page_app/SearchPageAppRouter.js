var _                    = require('underscore'),
    queryString          = require('query-string'),
    FilterActionCreators = require('./actions/FilterActionCreators'),
    CardActionCreators = require('./actions/CardActionCreators'),
    LocationStore        = require('./stores/LocationStore'),
    CardStore            = require('./stores/CardStore'),
    SubjectStore         = require('./stores/SubjectStore');

// Params that we store in URLs
var PARAMS_IN_SEARCH = {
    context         : { name: 'type'      , actionMethod: FilterActionCreators.changeContext },
    full_text_search: { name: 'discipline', actionMethod: FilterActionCreators.searchFullText },
    metro_lines     : { name: 'metros[]'  , actionMethod: FilterActionCreators.selectMetroLines },
    // page            : { name: 'page',       actionMethod: CardActionCreators.goToPage },
};

var SearchPageAppRouter = Backbone.Router.extend({

    // routes: {
    //   ':root_subject_id/:subject_id--:city_id' : 'navigate'
    //   ':root_subject_id--:city_id'
    //   ':city_id'
    // },

    initialize: function initialize () {
        _.bindAll(this, 'updateUrl');
    },

    updateUrl: function updateUrl () {
        var search_params = this.buildSearchParams();
        // /:city_id | /paris-12
        if (!SubjectStore.selected_subject && !SubjectStore.selected_root_subject && LocationStore.get('address')) {
            this.navigate(LocationStore.getCitySlug() + search_params);
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (SubjectStore.selected_root_subject && SubjectStore.selected_subject && LocationStore.get('address')) {
            this.navigate(SubjectStore.selected_root_subject.slug + '/' + SubjectStore.selected_subject.slug + '--' + LocationStore.getCitySlug() + search_params);
        } else if (LocationStore.get('address') && SubjectStore.selected_root_subject) {
            this.navigate(SubjectStore.selected_root_subject.slug + '--' + LocationStore.getCitySlug() + search_params);
        }
    }.debounce(500),

    buildSearchParams: function buildSearchParams () {
        var algolia_filters = CardStore.algoliaFilters();
        var search_params   = {};
        _.each(PARAMS_IN_SEARCH, function(value, key) {
            // Skip if there is no filters
            if (!algolia_filters[key]) { return ''; }
            search_params[value.name] = algolia_filters[key];
        });
        search_params = $.param(search_params);
        return (search_params.length == 0 ? '' : '?' + search_params);
    },

    bootsrapData: function bootsrapData () {
        var url_parameters = queryString.parse(location.search);
        _.each(PARAMS_IN_SEARCH, function(value, key) {
            value.actionMethod(url_parameters[value.name]);
        });
    },
});

module.exports = SearchPageAppRouter;

