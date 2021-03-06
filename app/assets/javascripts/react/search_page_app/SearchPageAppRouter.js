var _                      = require('lodash'),
    queryString            = require('query-string'),
    FilterActionCreators   = require('./actions/FilterActionCreators'),
    TimeActionCreators     = require('./actions/TimeActionCreators'),
    AudienceActionCreators = require('./actions/AudienceActionCreators'),
    LevelActionCreators    = require('./actions/LevelActionCreators'),
    CardActionCreators     = require('./actions/CardActionCreators'),
    LocationActionCreators = require('./actions/LocationActionCreators'),
    SliderActionCreators   = require('./actions/SliderActionCreators'),
    SubjectActionCreators  = require('./actions/SubjectActionCreators'),
    LocationStore          = require('./stores/LocationStore'),
    CardStore              = require('./stores/CardStore'),
    SubjectStore           = require('./stores/SubjectStore');

// Params that we store in URLs
// name is the name of the param in the URL
var PARAMS_IN_SEARCH = {
    'group_subject.group_id': { name: 'groupe'     , actionMethod: SubjectActionCreators.selectGroupSubjectById },
    context                 : { name: 'type'       , actionMethod: FilterActionCreators.changeContext },
    full_text_search        : { name: 'discipline' , actionMethod: FilterActionCreators.initSearchFullText },
    metro_lines             : { name: 'metros[]'   , actionMethod: FilterActionCreators.selectMetroLines },
    metro_stop              : { name: 'metro_stop' , actionMethod: FilterActionCreators.bootstrapSelectMetroStop },
    planning_periods        : { name: 'plannings[]', actionMethod: TimeActionCreators.togglePeriodsSelection },
    audiences               : { name: 'public[]'   , actionMethod: AudienceActionCreators.setAudiences },
    levels                  : { name: 'niveau[]'   , actionMethod: LevelActionCreators.setLevels },
    prices                  : { name: 'prix[]'     , actionMethod: SliderActionCreators.setPriceBounds },
    'training_dates.start'  : { name: 'start_date' , actionMethod: TimeActionCreators.setTrainingStartDate },
    'training_dates.end'    : { name: 'end_date'   , actionMethod: TimeActionCreators.setTrainingEndDate },
    sort_by                 : { name: 'sort'       , actionMethod: FilterActionCreators.updateSorting },
    actual_page             : { name: 'page'       , actionMethod: CardActionCreators.goToPage, delay: 500 },
    zoom                    : { name: 'zoom'       , actionMethod: LocationActionCreators.updateZoom, delay: 500 }
};

var SearchPageAppRouter = Backbone.Router.extend({

    // routes: {
    //   ':root_subject_id/:subject_id--:city_id' : 'navigate'
    //   ':root_subject_id--:city_id'
    //   ':city_id'
    // },

    initialize: function initialize () {
        _.bindAll(this, 'updateUrl');
        window.onpopstate = this.bootsrapData.bind(this);
    },

    updateUrl: function updateUrl () {
        // We prevent from updating url while asking for user position because it will dismiss
        // the popup on Chrome
        if (LocationStore.get('finding_user_position')) { return; }
        var new_location,
            search_params = this.buildSearchParams();
        // /:city_id | /paris-12
        if (!SubjectStore.selected_subject && !SubjectStore.selected_root_subject) {
            new_location = LocationStore.getCitySlug() + search_params;
        //  /:root_subject_id--:city_id | /danse--paris-12
        } else if (SubjectStore.selected_root_subject && SubjectStore.selected_subject) {
            new_location = SubjectStore.selected_root_subject.slug + '/' + SubjectStore.selected_subject.slug + '--' + LocationStore.getCitySlug() + search_params;
        } else if (SubjectStore.selected_root_subject) {
            new_location = SubjectStore.selected_root_subject.slug + '--' + LocationStore.getCitySlug() + search_params;
        }
        // Prevent from adding the stack same url in history
        if ((location.pathname + location.search) == ('/' + new_location)) { return; }
        this.navigate(new_location);
    }.debounce(500),

    /*
     * From ther filters that are passed to algolia (`CardStore.algoliaFilters()`), we build a hash
     * of values and convert them into search_params (`?foo=bar&bar=foo`)
     */
    buildSearchParams: function buildSearchParams () {
        var algolia_filters = CardStore.algoliaFilters();
        var search_params   = {};
        _.each(PARAMS_IN_SEARCH, function(value, key) {
            // Skip if there is no filters
            if (_.isUndefined(_.get(algolia_filters, key))) { return ''; }
            search_params[value.name] = _.get(algolia_filters, key);
        });
        search_params = $.param(search_params);
        return (search_params.length == 0 ? '' : '?' + search_params);
    },

    /*
     * We convert search_params (`?foo=bar&bar=foo`) into hash and we trigger actions to update stores
     */
    bootsrapData: function bootsrapData () {
        var url_parameters = queryString.parse(location.search);
        FilterActionCreators.clearAllTheData();
        _.each(PARAMS_IN_SEARCH, function(value, key) {
            if (url_parameters[value.name]) {
                if (value.delay) {
                  setTimeout(function() {
                      value.actionMethod(url_parameters[value.name]);
                  }, value.delay);
                } else {
                    value.actionMethod(url_parameters[value.name]);
                }
            }
        });
    },
});

module.exports = SearchPageAppRouter;

