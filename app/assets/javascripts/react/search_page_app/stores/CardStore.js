var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SubjectStore         = require('../stores/SubjectStore'),
    FilterStore          = require('../stores/FilterStore'),
    LocationStore        = require('../stores/LocationStore'),
    TimeStore            = require('../stores/TimeStore'),
    AudienceStore        = require('../stores/AudienceStore'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var CardModel = Backbone.Model.extend({});

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
        // Bind search events to the store, so it updates.
        AlgoliaSearchUtils.card_search_helper.on("result",  this.searchSuccess);
        AlgoliaSearchUtils.card_search_helper.on("error",  this.searchError);
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
            case ActionTypes.TOGGLE_AUDIENCE:
                // Make sure the Filter store has finish everything he needs to do.
                SearchPageDispatcher.waitFor([ FilterStore.dispatchToken, TimeStore.dispatchToken, AudienceStore.dispatchToken ]);
                // Fetch the new cards.
                this.fetchDataFromServer();
                break;
            case ActionTypes.GO_TO_PAGE:
                this.current_page = payload.data;
                this.fetchDataFromServer();
            case ActionTypes.GO_TO_PREVIOUS_PAGE:
                this.current_page = this.current_page - 1;
                this.fetchDataFromServer();
            case ActionTypes.GO_TO_NEXT_PAGE:
                this.current_page = this.current_page + 1;
                this.fetchDataFromServer();
                break;
            case ActionTypes.HIGHLIGHT_MARKER:
                // console.log('highlight maker');
                break;
            case ActionTypes.UNHIGHLIGHT_MARKER:
                // console.log('unhighlight maker');
                break;
        }
    },

    fetchDataFromServer: function fetchDataFromServer () {
        this.error   = false;
        this.loading = true;

        this.trigger('change');

        // Call the algolia search.
        AlgoliaSearchUtils.searchCards(this.algoliaFilters());
    }.debounce(150),

    searchSuccess: function searchSuccess (data) {
        this.loading = false;
        this.error   = false;

        // This triggers the change event.
        this.facets        = data.facets;
        this.total_results = data.nbHits;
        this.total_pages   = data.nbPages;
        this.reset(data.hits);
    },

    searchError: function searchError (data) {
        this.loading = false;
        this.error   = true;
    },

    algoliaFilters: function algoliaFilters () {
        var data = {
            page: this.current_page
        };
        if (SubjectStore.selected_group_subject)  { data.group_subject    = SubjectStore.selected_group_subject }
        if (SubjectStore.selected_root_subject)   { data.root_subject     = SubjectStore.selected_root_subject }
        if (SubjectStore.selected_subject)        { data.subject          = SubjectStore.selected_subject }
        if (SubjectStore.full_text_search)        { data.full_text_search = SubjectStore.full_text_search }
        if (TimeStore.algoliaFilters())           { data.planning_periods = TimeStore.algoliaFilters() }
        if (AudienceStore.algoliaFilters())       { data.audiences        = AudienceStore.algoliaFilters() }
        if (LocationStore.get('bounds')) {
            data.insideBoundingBox = LocationStore.get('bounds').toString();
        }
        if (LocationStore.get('user_location')) {
            data.aroundLatLng = LocationStore.get('user_location').latitude + ',' + LocationStore.get('user_location').longitude;
        } else if (LocationStore.get('address')) {
            data.aroundLatLng = LocationStore.get('address').latitude + ',' + LocationStore.get('address').longitude;
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
        return filters;
    },

    isFirstPage: function isFirstPage () {
        return (this.current_page == 1);
    },

    isLastPage: function isLastPage () {
        return (this.current_page == this.total_pages)
    }
});

module.exports = new CardCollection();
