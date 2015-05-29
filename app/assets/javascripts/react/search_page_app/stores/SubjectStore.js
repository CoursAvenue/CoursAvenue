var Backbone             = require('Backbone'),
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var SubjectModel = Backbone.Model.extend({});

var SubjectCollection = Backbone.Collection.extend({
    model: SubjectModel,

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
            case ActionTypes.SELECT_SUBJECT:
                this.fetchDataFromServer({ parent: payload.data });
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
