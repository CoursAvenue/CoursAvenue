var Backbone             = require('Backbone'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    FilterStore          = require('../stores/FilterStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var SubjectModel = Backbone.Model.extend({});

var SubjectCollection = Backbone.Collection.extend({
    model: SubjectModel,
    selected: false,
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
        if (this.isEmpty()) { this.fetchDataFromServer({ depth: 0 }); }
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.UPDATE_FILTER:
                SearchPageDispatcher.waitFor([FilterStore.dispatchToken]);
                this.fetchDataFromServer();
                break;
            case ActionTypes.SELECT_ROOT_SUBJECT:
                this.fetchDataFromServer({ root: payload.data });
                break;
            case ActionTypes.TOGGLE_SUBJECT_FILTERS:
                this.selected = !this.selected;
                this.trigger('change');
                break;
        }
    },

    fetchDataFromServer:  function fetchDataFromServer (data) {
        AlgoliaSearchUtils.searchSubjects(data).then(function(content){
            this.reset(content.hits);
        }.bind(this)).catch(function(error) {
            this.error   = true;
            this.trigger('change');
        }.bind(this));
    }
});

// the Store is an instantiated Collection; a singleton.
module.exports = new SubjectCollection();
