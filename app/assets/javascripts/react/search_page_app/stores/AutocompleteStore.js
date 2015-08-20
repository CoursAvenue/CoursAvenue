var _                    = require('lodash'),
    Backbone             = require('backbone'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    LocationStore        = require('./LocationStore'),
    FilterStore          = require('./FilterStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var AutocompleteStore = Backbone.Model.extend({

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'searchDone');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.set({ selected_subject_index: 0 });
        this.select_highlighted_suggestion = false;
    },

    dispatchCallback: function dispatchCallback (payload) {
        this.select_highlighted_suggestion = false;
        switch(payload.actionType) {
            case ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:
            case ActionTypes.SELECT_SUBJECT:
                this.set({ full_text_search: '' });
                break;
            case ActionTypes.INIT_SEARCH_FULL_TEXT:
            case ActionTypes.SUBJECT_SEARCH_FULL_TEXT:
                this.set({ full_text_search: payload.data });
                this.searchSubjects();
                break;
            case ActionTypes.FULL_TEXT_SELECT_SUGGESTION:
                this.set({ selected_subject_index: payload.data });
                break;
            case ActionTypes.FULL_TEXT_SELECT_NEXT_SUGGESTION:
                this.set({ selected_subject_index: (this.get('selected_subject_index') + 1) });
                break;
            case ActionTypes.FULL_TEXT_SELECT_PREVIOUS_SUGGESTION:
                this.set({ selected_subject_index: (this.get('selected_subject_index') - 1) });
                break;
            case ActionTypes.FULL_TEXT_SELECT_HIGHLIGHTED_SUGGESTION:
                this.set({ select_highlighted_suggestion: true });
                break;
        }
    },

    searchSubjects: function searchSubjects () {
        var insideBoundingBox;
        this.set({ selected_subject_index: 0 });
        if (LocationStore.get('bounds')) {
            insideBoundingBox = LocationStore.get('bounds').toString();
        }
        AlgoliaSearchUtils.searchAutocomplete(this.get('full_text_search'), this.searchDone, insideBoundingBox);
    },

    searchDone: function searchDone (err, content) {
        if (err) {
            this.error   = true;
            this.trigger('change');
            return;
        }
        var subjects = content.results[0];
        var cards    = content.results[1];
        this.set('total_cards', cards.nbHits);
        this.set('subjects', new Backbone.Collection(subjects.hits));
        this.trigger('change');
    }.debounce(250),

});

// the Store is an instantiated Collection; a singleton.
module.exports = new AutocompleteStore();
