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
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.CLEAR_AND_CLOSE_SUBJECT_INPUT_PANEL:
            case ActionTypes.SELECT_SUBJECT:
                this.full_text_search = '';
                this.trigger('change');
                break;
            case ActionTypes.INIT_SEARCH_FULL_TEXT:
            case ActionTypes.SEARCH_FULL_TEXT:
                this.full_text_search = payload.data;
                this.searchSubjects();
                break;
        }
    },

    searchSubjects: function searchSubjects () {
        if (this.full_text_search.length < 3) { return ; }

        var data = { hitsPerPage: 15, facets: '*', numericFilters: 'depth>0' }
        AlgoliaSearchUtils.searchSubjects(data, this.full_text_search).then(function(content){
            this.reset(content.hits);
            this.trigger('change');
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    },

});

// the Store is an instantiated Collection; a singleton.
module.exports = new SubjectAutocompleteStore();
