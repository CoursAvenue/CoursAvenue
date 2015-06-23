var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SubjectStore         = require('../stores/SubjectStore'),
    FilterStore          = require('../stores/FilterStore'),
    LocationStore        = require('../stores/LocationStore'),
    TimeStore            = require('../stores/TimeStore'),
    PriceStore           = require('../stores/PriceStore'),
    AudienceStore        = require('../stores/AudienceStore'),
    LevelStore           = require('../stores/LevelStore'),
    MetroStopStore       = require('../stores/MetroStopStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var CardModel = Backbone.Model.extend({});
var HITS_PER_PAGES = 16;

var CardCollection = Backbone.Collection.extend({
    model:   CardModel,
    loading: false,
    error:   false,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'searchSuccess', 'searchError');

        // Register the store to the dispatcher, so it calls our callback on new actions.
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.current_page = 1;
        this.total_pages  = 1;
        this.sort_by      = 'distance';
        this.context      = 'course';
    },

    // The function called everytime there's a new action dispatched.
    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            // When the filters are updated, refetch the cards.
            case ActionTypes.UPDATE_BOUNDS:
            case ActionTypes.UPDATE_FILTERS:
            case ActionTypes.SELECT_GROUP_SUBJECT:
            case ActionTypes.SELECT_ROOT_SUBJECT:
            case ActionTypes.SELECT_SUBJECT:
            case ActionTypes.SEARCH_FULL_TEXT:
            case ActionTypes.UNSET_FILTER:
            case ActionTypes.TOGGLE_DAY_SELECTION:
            case ActionTypes.TOGGLE_PERIOD_SELECTION:
            case ActionTypes.SET_TRAINING_DATE:
            case ActionTypes.TOGGLE_AUDIENCE:
            case ActionTypes.SET_PRICE_BOUNDS:
            case ActionTypes.TOGGLE_LEVEL:
            case ActionTypes.SELECT_METRO_STOP:
                // Make sure the Filter store has finish everything he needs to do.
                SearchPageDispatcher.waitFor([ FilterStore.dispatchToken, TimeStore.dispatchToken,
                                               AudienceStore.dispatchToken, SubjectStore.dispatchToken,
                                               LevelStore.dispatchToken, PriceStore.dispatchToken,
                                               MetroStopStore.dispatchToken ]);
                // Fetch the new cards.
                this.fetchDataFromServer();
                break;
            case ActionTypes.UPDATE_SORTING:
                this.sort_by = payload.data;
                this.fetchDataFromServer();
            case ActionTypes.GO_TO_PAGE:
                this.current_page = payload.data;
                this.updateCardsShownRegardingPages();
            case ActionTypes.GO_TO_PREVIOUS_PAGE:
                this.current_page = this.current_page - 1;
                this.updateCardsShownRegardingPages();
            case ActionTypes.GO_TO_NEXT_PAGE:
                this.current_page = this.current_page + 1;
                this.updateCardsShownRegardingPages();
                break;
            case ActionTypes.CHANGE_CONTEXT:
                this.context = payload.data;
                this.fetchDataFromServer();
                break;
            case ActionTypes.HIGHLIGHT_MARKER:
                _.invoke(this.models, 'set', { highlighted: false }, { silent: true })
                payload.data.card.set({ highlighted: true });
                break;
            case ActionTypes.UNHIGHLIGHT_MARKERS:
                _.invoke(this.models, 'set', { highlighted: false }, { silent: true })
                break;
        }
    },

    fetchDataFromServer: function fetchDataFromServer () {
        this.error   = false;
        this.loading = true;

        this.trigger('change');

        // Call the algolia search.
        AlgoliaSearchUtils.searchCards(this.algoliaFilters(), this.searchSuccess, this.searchError);
    }.debounce(150),

    searchSuccess: function searchSuccess (data) {
        this.loading = false;
        this.error   = false;

        // This triggers the change event.
        this.facets        = data.facets;
        this.total_results = data.nbHits;
        this.total_pages   = Math.ceil(this.total_results / HITS_PER_PAGES);
        this.reset(data.hits);
        this.current_page = 1;
        this.updateCardsShownRegardingPages();
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },

    algoliaFilters: function algoliaFilters () {
        var data = {
            page   : this.current_page,
            sort_by: this.sort_by,
            context: this.context
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
        } else if (LocationStore.get('address')) {
            data.aroundLatLng = LocationStore.get('address').latitude + ',' + LocationStore.get('address').longitude;
        }
        if ((metro_stop = MetroStopStore.getSelectedStop())) {
            data.aroundLatLng = metro_stop.get('latitude') + ',' + metro_stop.get('longitude');
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
            filters.push({ title: SubjectStore.selected_group_subject.name, filter_key: 'group_subject' });
        }
        if (SubjectStore.selected_root_subject) {
            filters.push({ title: SubjectStore.selected_root_subject.name, filter_key: 'root_subject' });
        }
        if (SubjectStore.selected_subject) {
            filters.push({ title: SubjectStore.selected_subject.name, filter_key: 'subject' });
        }
        if (LocationStore.isUserLocated()) {
            filters.push({ title: "Autour de moi", filter_key: 'user_location' });
        } else if (LocationStore.isFilteredByAddress()) {
            filters.push({ title: "Adresse", filter_key: 'address' });
        }
        if (TimeStore.isFiltered()) {
            filters.push({ title: "Planning", filter_key: 'time_store' });
        }
        if (AudienceStore.algoliaFilters()) {
            filters.push({ title: "Public", filter_key: 'audiences' });
        }
        if (LevelStore.algoliaFilters()) {
            filters.push({ title: "Niveau", filter_key: 'levels' });
        }
        if (PriceStore.algoliaFilters()) {
            filters.push({ title: "Prix", filter_key: 'price' });
        }
        return filters;
    },

    isFirstPage: function isFirstPage () {
        return (this.current_page == 1);
    },

    isLastPage: function isLastPage () {
        return (this.current_page == this.total_pages)
    },

    updateCardsShownRegardingPages: function updateCardsShownRegardingPages () {
        // Unselect all models
        this.map(function(card) {
            card.set({ visible: false }, { silent: true });
        });
        var selected_models_range = _.range((this.current_page - 1) * HITS_PER_PAGES, this.current_page * HITS_PER_PAGES);
        _.each(selected_models_range, function(card_index) {
            // Don't select not existing models, of course.
            if (card_index > (this.length - 1)) { return; }
            this.models[card_index].set({ visible: true }, { silent: true });
        }.bind(this));
        this.trigger('change');
    }
});

module.exports = new CardCollection();
