// var AppDispatcher = require('../dispatcher/AppDispatcher');

var Backbone      = require('Backbone'),
    PlanningStore = require('./PlanningStore');

module.exports = Backbone.Collection.extend({
    model: PlanningStore
});
