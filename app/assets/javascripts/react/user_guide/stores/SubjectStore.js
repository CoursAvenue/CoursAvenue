var _                   = require('underscore'),
    Backbone            = require('backbone'),
    AnswerStore         = require('./AnswerStore'),
    UserGuideConstants  = require('../constants/UserGuideConstants'),
    UserGuideDispatcher = require('../dispatcher/UserGuideDispatcher'),
    ActionTypes         = UserGuideConstants.ActionTypes;

var Subject = Backbone.Model.extend({
  defaults: function defaults () {
    return { score: 0 };
  },

  initialize: function initialize () {
  },

});

var SubjectStore = Backbone.Collection.extend({
  model: Subject,
  // Order by score ASC.
  comparator: 'score',

  initialize: function initialize () {
    _.bindAll(this, 'dispatchCallback', 'updateScores');
    this.dispatchToken = UserGuideDispatcher.register(this.dispatchCallback);
  },

  dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.SELECT_ANSWER:
              UserGuideDispatcher.waitFor([AnswerStore.dispatchToken]);
              this.updateScores(payload.data);
              break;
        }
  },

  updateScores: function updateScores (data) {
    // TODO: Increment score thanks to ponderation.
    // TODO: Find a way to remove score if it is an updated answer.
    this.trigger('change');
  },

});

module.exports = new SubjectStore();
