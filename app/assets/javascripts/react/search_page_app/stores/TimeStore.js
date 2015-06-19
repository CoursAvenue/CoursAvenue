var _                    = require('underscore'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;
var PERIODS = ['morning', 'noon', 'afternoon', 'evening'];

// A day in the time table.
var DayColumn = Backbone.Model.extend({
    defaults: function defaults() {
        return { periods: [false, false, false, false] }
    },

    initialize: function initialize () {
        _.bindAll(this, 'toAlgolia', 'setPeriod');
    },

    // Returns the current day periods as algolia filters, e.g. `monday-afternoon`.
    toAlgolia: function toAlgolia () {
        var filters = this.get('periods').map(function(selected, index) {
            if (selected) {
                return this.get('name') + "-" + PERIODS[index];
            }
        }.bind(this));

        return filters;
    },

    // Select the period whose index is passed.
    setPeriod: function setPeriod (periodIndex) {
        periods = this.get('periods');
        periods[periodIndex] = true;
        this.set('periods', periods);
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
                break;
            case ActionTypes.TOGGLE_PERIOD_SELECTION:
                this.togglePeriodSelection(payload.data);
                break;
            case ActionTypes.UNSET_FILTER:
                if (payload.data == 'time_store') {
                    this.map(function(day) {
                        day.set({ selected: false, periods: [false, false, false, false] },
                                { silent: true });
                    });
                    this.trigger('change');
                }
                break;
        }
    },

    toggleDaySelection: function toggleDaySelection (day) {
        day.set({ selected: !day.get('selected')})
        day.set('periods', [day.get('selected'), day.get('selected'), day.get('selected'), day.get('selected')]);
        this.trigger('change');
    },

    togglePeriodSelection: function toggleDaySelection (data) {
        var day         = data.day;
        var periodIndex = data.period;
        var periods     = day.get('periods');

        periods[periodIndex] = !periods[periodIndex]
        day.set('periods', periods);

        // Checking if every period is set to true.
        if (_.every(periods, _.identity)) {
            day.set({ selected: true });
        } else {
            day.set({ selected: false });
        }

        this.trigger('change');
    },

    algoliaFilters: function algoliaFilters () {
        var filters = this.models.map(function(model) {
            return model.toAlgolia();
        });
        filters = _.chain(filters).flatten().compact().value();

        if (_.isEmpty(filters)) {
            return false;
        }

        return filters;
    },

    setFilters: function setFilters (filters) {
        filters.each(function(filter) {
            var attributes = filter.split('-');
            var day = this.findWhere({ name: attributes[0] });
            var periodIndex = PERIODS.indexOf(attributes[1]);

            if (day && periodIndex != -1) {
                day.setPeriod(periodIndex);
            }
        }.bind(this));

        this.trigger('change');
    },

    /*
     * Tell wether there is active filters
     */
    isFiltered: function isFiltered() {
        return this.some(function(day) {
            return _.some(day.get('periods'), function(period) {
                return period;
            });
        });
    }
});

module.exports = new TimeStore([
    { title: 'Lun.', name: 'monday'   , selected: false },
    { title: 'Mar.', name: 'tuesday'  , selected: false },
    { title: 'Mer.', name: 'wednesday', selected: false },
    { title: 'Jeu.', name: 'thursday' , selected: false },
    { title: 'Ven.', name: 'friday'   , selected: false },
    { title: 'Sam.', name: 'saturday' , selected: false },
    { title: 'Dim.', name: 'sunday'   , selected: false }
]);
