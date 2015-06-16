var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

// A day in the time table.
var DayColumn = Backbone.Model.extend({
    defaults: {
        periods: [false, false, false, false],
    },
});

var TimeStore = Backbone.Collection.extend({
    model: DayColumn,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'toggleDaySelection');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.TOGGLE_DAY_SELECTION:
                this.toggleDaySelection(payload.data);
                console.log(payload);
                break;
        }
    },

    toggleDaySelection: function toggleDaySelection (day) {
        debugger
    },
});

module.exports = new TimeStore([
    { title: 'Lun.' }, { title: 'Mar.' }, { title: 'Mer.' }, { title: 'Jeu.' },
    { title: 'Ven.' }, { title: 'Sam.' }, { title: 'Dim.' }
]);
