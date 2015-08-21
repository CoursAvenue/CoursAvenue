var _                    = require('lodash'),
    Backbone             = require('backbone'),
    SubjectStore         = require('../stores/SubjectStore'),
    FilterStore          = require('../stores/FilterStore'),
    LocationStore        = require('../stores/LocationStore'),
    TimeStore            = require('../stores/TimeStore'),
    UserStore            = require('../stores/UserStore'),
    PriceStore           = require('../stores/PriceStore'),
    AudienceStore        = require('../stores/AudienceStore'),
    LevelStore           = require('../stores/LevelStore'),
    MetroStopStore       = require('../stores/MetroStopStore'),
    MetroLineStore       = require('../stores/MetroLineStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var CardModel = Backbone.Model.extend({
    defaults: function defaults () {
        return {
            favorite: false,
        };
    },

    initialize: function initialize () {
        _.bindAll(this, 'toggleFavorite');
    },

    toggleFavorite: function toggleFavorite () {
        var favorite = this.get('favorite');
        this.set('favorite', !favorite);
    },

    index: function index () {
        if (!this.collection) { return (-1); }

        return this.collection.indexOf(this);
    },
});

var CardCollection = Backbone.Collection.extend({
    HITS_PER_PAGES          : 16,
    NB_PAGE_LOADED_PER_BATCH: 6,

    model        :   CardModel,
    first_loading: true,
    error        :   false,

    initialize: function initialize () {
	_.bindAll(this, 'dispatchCallback', 'searchSuccess', 'searchError', 'fetchDataFromServer');

	// Register the store to the dispatcher, so it calls our callback on new actions.
	this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.current_page = 1;
        this.total_pages  = 1;
        this.context      = 'course';
        this.sort_by      = 'by_popularity_desc';
    },

    // The function called everytime there's a new action dispatched.
    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.FILTER_BY_CARD_IDS:
                this.filtered_ids = payload.data;
                break;
            case ActionTypes.TOGGLE_DAY_SELECTION:
            case ActionTypes.TOGGLE_PERIOD_SELECTION:
            case ActionTypes.TOGGLE_PERIODS_SELECTION:
                // We debounce that much to prevent from blocking UI.
                _.debounce(this.fetchDataFromServer, 1500)(true);
                break;
            // When the filters are updated, refetch the cards.
            case ActionTypes.UPDATE_NB_CARDS_PER_PAGE:
                this.HITS_PER_PAGES = payload.data;
                this.fetchDataFromServer(true);
                break;
            case ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:
            case ActionTypes.SEARCH_FULL_TEXT:
            case ActionTypes.SEARCH:
            case ActionTypes.UPDATE_BOUNDS:
            case ActionTypes.UPDATE_FILTERS:
            case ActionTypes.SELECT_GROUP_SUBJECT:
            case ActionTypes.SELECT_ROOT_SUBJECT:
            case ActionTypes.SELECT_SUBJECT:
            case ActionTypes.UNSET_FILTER:
            case ActionTypes.SET_TRAINING_DATE:
            case ActionTypes.SET_TRAINING_START_DATE:
            case ActionTypes.SET_TRAINING_END_DATE:
            case ActionTypes.TOGGLE_AUDIENCE:
            case ActionTypes.SET_AUDIENCES:
            case ActionTypes.SET_PRICE_BOUNDS:
            case ActionTypes.TOGGLE_LEVEL:
            case ActionTypes.SET_LEVELS:
            case ActionTypes.SELECT_METRO_STOP:
            case ActionTypes.SELECT_METRO_LINE:
            case ActionTypes.SELECT_METRO_LINES:
                // Make sure the Filter store has finish everything he needs to do.
                SearchPageDispatcher.waitFor([ FilterStore.dispatchToken, TimeStore.dispatchToken,
                                               AudienceStore.dispatchToken, SubjectStore.dispatchToken,
                                               LevelStore.dispatchToken, PriceStore.dispatchToken,
                                               MetroStopStore.dispatchToken, MetroLineStore.dispatchToken,
                                               LocationStore.dispatchToken]);
                // Fetch the new cards.
                this.fetchDataFromServer(true);
                break;
            case ActionTypes.UPDATE_SORTING:
                this.sort_by = payload.data;
                this.fetchDataFromServer(true);
                break;
            case ActionTypes.GO_TO_PAGE:
                this.current_page = parseInt(payload.data, 10);
                this.updateCardsShownRegardingPages();
                this.trigger('page:change');
                break;
            case ActionTypes.GO_TO_PREVIOUS_PAGE:
                this.current_page = this.current_page - 1;
                this.updateCardsShownRegardingPages();
                this.trigger('page:change');
                break;
            case ActionTypes.GO_TO_NEXT_PAGE:
                this.current_page = this.current_page + 1;
                this.updateCardsShownRegardingPages();
                this.trigger('page:change');
                break;
            case ActionTypes.CHANGE_CONTEXT:
                this.context = payload.data;
                this.fetchDataFromServer(true);
                break;
            case ActionTypes.CARD_HOVERED:
                this.a_card_is_hovered = payload.data.hovered;
                payload.data.card.set({ hovered: payload.data.hovered });
                break;
            case ActionTypes.HIGHLIGHT_MARKER:
                _.invoke(this.models, 'set', { highlighted: false }, { silent: true });
                payload.data.card.set({ highlighted: true });
                break;
            case ActionTypes.UNHIGHLIGHT_MARKERS:
                _.invoke(this.models, 'set', { highlighted: false }, { silent: true });
                break;
            case ActionTypes.DISMISS_HELP:
                this.updateCardsShownRegardingPages();
                break;
            case ActionTypes.TOGGLE_FAVORITE:
                payload.data.card.toggleFavorite();
                this.trigger('change');
                break;
        }
    },

    fetchDataFromServer: function fetchDataFromServer (reset_page_nb) {
        if (reset_page_nb) { this.current_page = 1; }
        this.error   = false;

        // Call the algolia search.
        AlgoliaSearchUtils.searchCards(this.algoliaFilters(), this.searchSuccess, this.searchError);
    }.debounce(150),

    searchSuccess: function searchSuccess (data) {
        this.first_loading = false;
        this.error         = false;

        this.facets        = data.facets;
        this.total_results = data.nbHits;
        this.total_pages   = Math.ceil(data.nbHits / this.HITS_PER_PAGES);
        // We affect batch page to results to be able to know if we have to load results of a specific page
        var batch_page = this.batchPage();
        _.each(data.hits, function(hit, index) {
            hit.batch_page = batch_page;
            hit.page       = (batch_page * this.NB_PAGE_LOADED_PER_BATCH) - this.NB_PAGE_LOADED_PER_BATCH + (Math.floor(index / this.HITS_PER_PAGES) + 1);
            if (_.includes(UserStore.favorites(), hit.id)) {
                hit.favorite = true;
            }
        }.bind(this));
        // We reset results if the search was made for page 1
        if (this.batchPage() == 1) {
            this.reset(data.hits, { silent: true });
        } else {
            this.add(data.hits, { silent: true });
        }
        if (data.hits.length > 0) { this.updateCardsShownRegardingPages(); }
        this.trigger('reset');
        this.trigger('search:done');
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },

    /*
     * As we load `NB_PAGE_LOADED_PER_BATCH` pages each time we fetch the server, we want to know
     * the page number that correspond to Algolia's request
     * Ex.
     *  NB_PAGE_LOADED_PER_BATCH: 2 and current_page = 3
     *    => batchPage: 2
     */
    batchPage: function batchPage () {
        return Math.ceil(this.current_page /this.NB_PAGE_LOADED_PER_BATCH);
    },

    // We load next batch ONLY if we do not have results of this batch
    shouldLoadNextBatch: function shouldLoadNextBatch () {
        if (this.length == 0) { return false; }
        return _.isUndefined(this.findWhere({batch_page: this.batchPage()}));
    },

    algoliaFilters: function algoliaFilters () {
        var data = {
            hitsPerPage: this.HITS_PER_PAGES * this.NB_PAGE_LOADED_PER_BATCH,
            page       : this.batchPage() - 1, // Pages starts at 0
            actual_page: this.current_page, // Needed for routing
            sort_by    : this.sort_by,
            context    : this.context
        };
        if (SubjectStore.selected_group_subject)  { data.group_subject    = SubjectStore.selected_group_subject }
        if (SubjectStore.selected_root_subject)   { data.root_subject     = SubjectStore.selected_root_subject }
        if (SubjectStore.selected_subject)        { data.subject          = SubjectStore.selected_subject }
        if (AudienceStore.algoliaFilters())       { data.audiences        = AudienceStore.algoliaFilters() }
        if (PriceStore.algoliaFilters())          { data.prices           = PriceStore.algoliaFilters() }
        if (LevelStore.algoliaFilters())          { data.levels           = LevelStore.algoliaFilters() }
        if (!_.isUndefined(SubjectStore.full_text_search)) { data.full_text_search = SubjectStore.full_text_search }
        if (LocationStore.get('bounds')) {
            data.insideBoundingBox = LocationStore.get('bounds').toString();
        }
        if (LocationStore.get('user_location')) {
            data.aroundLatLng = LocationStore.get('user_location').latitude + ',' + LocationStore.get('user_location').longitude;
        } else if (MetroStopStore.getSelectedStop()) {
            data.aroundLatLng = MetroStopStore.getSelectedStop().coordinates().toString();
        } else if (LocationStore.isFilteredByAddress() && LocationStore.get('address')) {
            data.aroundLatLng = LocationStore.get('address').latitude + ',' + LocationStore.get('address').longitude;
        }

        // Do not filter by line if a stop is selected, because if a stop is selected,
        // we'll filter around a location
        if (MetroLineStore.getSelectedLines().length > 0 && !MetroStopStore.getSelectedStop()) {
            data.metro_lines =_.map(MetroLineStore.getSelectedLines(), function(line) {
                return line.get('slug')
            });
        }

        if (this.filtered_ids) {
            data.ids = this.filtered_ids;
        }
        if (TimeStore.isFiltered()) {
            if (data.context == 'course') {
                data.planning_periods = TimeStore.algoliaFilters()
            } else {
                data.training_dates = TimeStore.trainingDates();
            }
        }

        return data;
    },

    getBreadcrumbFilters: function getBreadcrumbFilters () {
        var filters = [];
        if (SubjectStore.selected_group_subject) {
            filters.push({ title     : SubjectStore.selected_group_subject.name,
                           type      : 'subject',
                           filter_key: 'group_subject' });
        }
        if (SubjectStore.selected_root_subject) {
            filters.push({ title     : SubjectStore.selected_root_subject.name,
                           type      : 'subject',
                           filter_key: 'root_subject' });
        }
        if (SubjectStore.selected_subject) {
            filters.push({ title     : SubjectStore.selected_subject.name,
                           type      : 'subject',
                           filter_key: 'subject' });
        }
        if (SubjectStore.full_text_search) {
            filters.push({ title     : SubjectStore.full_text_search,
                           type      : 'subject',
                           filter_key: 'full_text_search' });
        }
        if (LocationStore.isUserLocated()) {
            filters.push({ title     : "Autour de moi",
                           type      : 'location',
                           filter_key: 'user_location' });
        } else if (LocationStore.isFilteredByAddress()) {
            filters.push({ title     : "Adresse",
                           type      : 'location',
                           filter_key: 'address' });
        }
        if (MetroStopStore.getSelectedStop() || MetroLineStore.getSelectedLines().length > 0 ) {
            filters.push({ title     : "Metro",
                           type      : 'location',
                           filter_key: 'metro' });
        }
        if (TimeStore.isFiltered()) {
            filters.push({ title     : "Planning",
                           type      : 'time',
                           filter_key: 'time_store' });
        }
        if (AudienceStore.algoliaFilters()) {
            filters.push({ title     : "Public",
                           type      : 'more',
                           filter_key: 'audiences' });
        }
        if (LevelStore.algoliaFilters()) {
            filters.push({ title     : "Niveau",
                           type      : 'more',
                           filter_key: 'levels' });
        }
        if (PriceStore.algoliaFilters()) {
            filters.push({ title     : "Prix",
                           type      : 'more',
                           filter_key: 'price' });
        }
        return filters;
    },

    hasActiveFilters: function hasActiveFilters (filter_type) {
        return _.detect(this.getBreadcrumbFilters(), function(breadcrumb) {
            return breadcrumb.type == filter_type;
        });
    },

    isFirstPage: function isFirstPage () {
        return (this.current_page == 1);
    },

    isLastPage: function isLastPage () {
        return (this.current_page == this.total_pages)
    },

    updateCardsShownRegardingPages: function updateCardsShownRegardingPages () {
        var selected_models = this.where({ page: this.current_page });
        // Unselect all models
        _.invoke(this.models, 'set', { visible: false }, { silent: true });
        _.each(selected_models, function(card) {
            card.set({ visible: true }, { silent: true });
        }.bind(this));
        if (this.shouldLoadNextBatch()) {
            this.fetchDataFromServer(false);
        }
        this.trigger('change:visible');
    }
});

module.exports = new CardCollection();
