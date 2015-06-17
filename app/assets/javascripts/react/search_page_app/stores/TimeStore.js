var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;

// A day in the time table.
var DayColumn = Backbone.Model.extend({
    defaults: function defaults() {
        return { periods: [false, false, false, false] }
    }
});

var TimeStore = Backbone.Collection.extend({
    model: DayColumn,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'toggleDaySelection');
        this.allSelected = false;

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.TOGGLE_DAY_SELECTION:
                this.toggleDaySelection(payload.data);
                break;
            case ActionTypes.TOGGLE_PERIOD_SELECTION:
                this.togglePeriodSelection(payload.data);
                break;
        }
    },

    toggleDaySelection: function toggleDaySelection (data) {
        this.allSelected = !this.allSelected;

        var day = this.get(data);
        day.set('periods', [this.allSelected, this.allSelected, this.allSelected, this.allSelected]);
        this.trigger('change');
    },

    togglePeriodSelection: function toggleDaySelection (data) {
        var day         = this.get(data.day);
        var periodIndex = data.period;
        var periods     = day.get('periods');

        periods[periodIndex] = !periods[periodIndex]
        day.set('periods', periods);

        // Checking if every period is set to true.
        if (_.every(periods, _.identity)) {
            this.allSelected = true;
        } else {
            this.allSelected = false;
        }

        this.trigger('change');
    },
});

module.exports = new TimeStore([
    { title: 'Lun.', name: 'monday' },
    { title: 'Mar.', name: 'tuesday' },
    { title: 'Mer.', name: 'wednesday' },
    { title: 'Jeu.', name: 'thursday' },
    { title: 'Ven.', name: 'friday' },
    { title: 'Sam.', name: 'saturday' },
    { title: 'Dim.', name: 'sunday' }
]);
