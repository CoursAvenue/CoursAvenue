var Backbone             = require('Backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

var PlanningModel = Backbone.Model.extend({});

var PlanningCollection = Backbone.Collection.extend({
    model: PlanningModel,
    loading: false,
    error: false,
    //url: "/todo",
    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.FILTERS__MAP_BOUNDS_CHANGED:
                // this.reloadBounds(payload.data);
                break;
            case ActionTypes.LOAD_PLANNINGS:
                this.loading = true;
                this.trigger('change');
                break;
            case ActionTypes.LOAD_PLANNINGS_SUCCESS:
                this.loading = false;
                this.reset(payload.data);
                break;
            case ActionTypes.LOAD_PLANNINGS_FAILURE:
                this.loading = false;
                this.error   = true;
                this.trigger('change');
                break;
        }
    },

    // reloadBounds: function reloadBounds (data) {
    //     debugger
    //     var data = { insideBoundingBox: data.toString() };
    //     this.index.search('', data, function searchDone(err, content) {
    //         this.collection.reset(content.hits);
    //     }
    // }
});

// the Store is an instantiated Collection; a singleton.
module.exports = new PlanningCollection();
