var _                    = require('lodash'),
    Backbone             = require('backbone'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    FilterStore          = require('./FilterStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

var SubjectAutocompleteStore = Backbone.Collection.extend({
    model: Backbone.Model.extend({}),

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        this.selected_index = 0;
        this.select_highlighted_suggestion = false;
    },

    dispatchCallback: function dispatchCallback (payload) {
        this.select_highlighted_suggestion = false;
        switch(payload.actionType) {
            case ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:
            case ActionTypes.SELECT_SUBJECT:
                this.full_text_search = '';
                this.trigger('change');
                break;
            case ActionTypes.INIT_SEARCH_FULL_TEXT:
            case ActionTypes.SUBJECT_SEARCH_FULL_TEXT:
                this.full_text_search = payload.data;
                this.searchSubjects();
                break;
            case ActionTypes.FULL_TEXT_SELECT_SUGGESTION:
                this.selected_index = payload.data
                this.trigger('change');
                break;
            case ActionTypes.FULL_TEXT_SELECT_NEXT_SUGGESTION:
                this.selected_index = this.selected_index + 1;
                this.trigger('change');
                break;
            case ActionTypes.FULL_TEXT_SELECT_PREVIOUS_SUGGESTION:
                this.selected_index = this.selected_index - 1;
                this.trigger('change');
                break;
            case ActionTypes.FULL_TEXT_SELECT_HIGHLIGHTED_SUGGESTION:
                this.select_highlighted_suggestion = true;
                this.trigger('change');
                break;
        }
    },

    searchSubjects: function searchSubjects () {
        if (this.full_text_search.length < 2) { return ; }
        this.selected_index = 0;

        var data = { hitsPerPage: 15, facets: '*', numericFilters: 'depth>0' }
        AlgoliaSearchUtils.searchSubjects(data, this.full_text_search).then(function(content){
            this.reset(content.hits);
            this.trigger('change');
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    }.debounce(250),

});

// the Store is an instantiated Collection; a singleton.
module.exports = new SubjectAutocompleteStore();
