var _                    = require('lodash'),
    Backbone             = require('backbone'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');

var ActionTypes = SearchPageConstants.ActionTypes;
var PERIODS = ['morning', 'noon', 'afternoon', 'evening'];
var ONE_DAY = 60 * 60 * 24;


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
    setPeriod: function setPeriod (period_index) {
        periods = this.get('periods');
        periods[period_index] = true;
        this.set('periods', periods);
    },
});

var TimeStore = Backbone.Collection.extend({
    model: DayColumn,

    initialize: function initialize () {
        _.bindAll(this, 'dispatchCallback', 'toggleDaySelection', 'unsetFilter',
                        'setTrainingDate', 'trainingDates');

        this.dispatchToken = SearchPageDispatcher.register(this.dispatchCallback);

        this.training_start_date = null;
        this.training_end_date   = null;
    },

    dispatchCallback: function dispatchCallback (payload) {
        switch(payload.actionType) {
            case ActionTypes.CHANGE_CONTEXT:
                this.unsetFilter('time_store');
                break;
            case ActionTypes.TOGGLE_DAY_SELECTION:
                this.toggleDaySelection(payload.data);
                break;
            case ActionTypes.TOGGLE_PERIODS_SELECTION:
                this.setPeriods(payload.data);
                break;
            case ActionTypes.TOGGLE_PERIOD_SELECTION:
                this.togglePeriodSelection(payload.data);
                break;
            case ActionTypes.SET_TRAINING_START_DATE:
                this.setTrainingDate({ value: payload.data, attribute: 'start_date'});
                break;
            case ActionTypes.SET_TRAINING_END_DATE:
                this.setTrainingDate({ value: payload.data, attribute: 'end_date'});
                break;
            case ActionTypes.SET_TRAINING_DATE:
                this.setTrainingDate(payload.data);
                break;
            case ActionTypes.CLEAR_ALL_THE_DATA:
                this.unsetFilter('time_store');
                break;
            case ActionTypes.UNSET_FILTER:
                this.unsetFilter(payload.data);
                break;
        }
    },

    toggleDaySelection: function toggleDaySelection (day) {
        day.set({ selected: !day.get('selected')})
        day.set('periods', [day.get('selected'), day.get('selected'), day.get('selected'), day.get('selected')]);
        this.trigger('change');
    },

    /*
     * @data [{ day: 'monday', period: 'afternoon' }]
     */
    setPeriods: function setPeriods (periods) {
        _.each(periods, function(period) {
            var day          = this.findWhere({name: period.day})
            day.setPeriod(PERIODS.indexOf(period.period));

            // Checking if every period is set to true.
            if (_.every(day.get('periods'), _.identity)) {
                day.set({ selected: true });
            } else {
                day.set({ selected: false });
            }
        }, this);

        this.trigger('change');
    },

    togglePeriodSelection: function togglePeriodSelection (data) {
        var day         = data.day;
        var period_index = data.period;
        var periods     = day.get('periods');

        periods[period_index] = !periods[period_index]
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
            var period_index = PERIODS.indexOf(attributes[1]);

            if (day && period_index != -1) {
                day.setPeriod(period_index);
            }
        }.bind(this));

        this.trigger('change');
    },

     unsetFilter: function unsetFilter(store) {
         if (store == 'time_store') {
             this.training_start_date = undefined;
             this.training_end_date   = undefined;
             this.map(function(day) {
                 day.set({ selected: false, periods: [false, false, false, false] },
                         { silent: true });
             });
             this.trigger('change');
         }
     },

    /*
     * Tell wether there is active filters
     */
    isFiltered: function isFiltered() {
        var filteredByPeriods = this.some(function(day) {
            return _.some(day.get('periods'), _.identity);
        });

        return filteredByPeriods || !!this.training_start_date || !!this.training_end_date;
    },

    getTrainingDate: function getTrainingDate (date_type) {
        if (date_type == 'start_date') {
            return (this.training_start_date ? new Date(this.training_start_date * 1000) : null);
        } else if (this.training_end_date > this.training_start_date) {
            return (this.training_end_date ? new Date((this.training_end_date - ONE_DAY) * 1000) : null);
        }
    },

    setTrainingDate: function setTrainingDate (date) {
        if (date.attribute == 'start_date') {
            this.training_start_date = date.value;
        } else {
            this.training_end_date = (date.value ? date.value + ONE_DAY : null);
        }
        this.trigger('change');
    },

    trainingDates: function trainingDates () {
        return { start: this.training_start_date, end: (this.training_end_date > this.training_start_date ? this.training_end_date : null) };
    },

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
