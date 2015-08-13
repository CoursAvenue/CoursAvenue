var _                  = require('lodash'),
    Backbone           = require('backbone'),
    StructureStore     = require('../stores/StructureStore'),
    CardPageDispatcher = require('../dispatcher/CardPageDispatcher'),
    CardPageConstants  = require('../constants/CardPageConstants'),
    ActionTypes        = CardPageConstants.ActionTypes;

var ThreadModel = Backbone.Model.extend({
    toJSON: function toJSON () {
        return { community_message_thread: this.attributes };
    },

    url: function url () {
        if (this.get('id')) {
            return Routes.structure_community_message_thread_path(StructureStore.get('slug'), this.get('id'));
        } else {
            return Routes.structure_community_message_threads_path(StructureStore.get('slug'));
        }
    }
});

var ThreadStore = Backbone.Collection.extend({
    model: ThreadModel,

    comparator: function comparator (a, b) {
        return (b.get('id') > a.get('id'));
    },

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback');
        this.dispatchToken = CardPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SET_STRUCTURE:
                CardPageDispatcher.waitFor([StructureStore.dispatchToken]);
                this.loadThreads();
                break;
            case ActionTypes.SUBMIT_NEW_THREAD:
                this.submitThread(payload.data);
                break;
            case ActionTypes.REPLY_TO_THREAD:
                this.replyToThread(payload.data);
                break;
        }
    },

    replyToThread: function replyToThread (data) {
        var message = this.findWhere({ id: data.id })
        message.set(data);
        message.save(null, {
            success: function success (model, response_model) {
                model.set(response_model);
            },
            error: function error (model, response) {
            }
        });
    },

    submitThread: function submitThread (data) {
        this.loading = true;
        this.trigger('change');
        var message = new ThreadModel(data);
        this.add(message);
        message.save(null, {
            success: function success (model, response_model) {
                this.loading = false;
                model.set(response_model);
                this.sort();
                this.trigger('change');
            }.bind(this),
            error: function error (model, response) {
                this.loading = false;
                this.trigger('change');
            }.bind(this)
        });
    },

    loadThreads: function loadThreads () {
        this.loading = true;
        $.get(Routes.structure_community_message_threads_path(StructureStore.get('slug')), function(data) {
            this.loading     = false;
            this.reset(data);
        }.bind(this), 'json');
    }
});

module.exports = new ThreadStore();
