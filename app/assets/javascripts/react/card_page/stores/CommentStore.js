var _                  = require('lodash'),
    Backbone           = require('backbone'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var PER_PAGE = 5;
var CommentModel = Backbone.Model.extend({});

var CommentStore = Backbone.Collection.extend({
    model: CommentModel,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
        this.loading      = true;
        this.current_page = 1;
        this.total        = 0;
        this.total_pages  = 1;
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_STRUCTURE_SLUG:
                this.structure_slug = payload.data;
                this.loadComments();
                break;
            case ActionTypes.GO_TO_PAGE:
                this.current_page = payload.data;
                this.loadComments();
                break;
            case ActionTypes.GO_TO_PREVIOUS_PAGE:
                this.current_page = this.current_page - 1;
                this.loadComments();
                break;
            case ActionTypes.GO_TO_NEXT_PAGE:
                this.current_page = this.current_page + 1;
                this.loadComments();
                break;
        }
    },

    isFirstPage: function isFirstPage () {
        return (this.current_page == 1);
    },

    isLastPage: function isLastPage () {
        return (this.current_page == this.total_pages)
    },

    loadComments: function loadComments () {
        this.loading = true;
        $.get(Routes.structure_comments_path(this.structure_slug, { page: this.current_page }), function(data) {
            this.total_pages = parseInt(data.meta.total_pages, 10);
            this.total       = data.meta.total;
            this.loading     = false;
            this.reset(data.comments);
        }.bind(this), 'json');
    }
});

module.exports = new CommentStore();
