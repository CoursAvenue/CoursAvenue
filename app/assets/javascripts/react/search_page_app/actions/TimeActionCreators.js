var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    toggleDaySelection: function toggleDaySelection (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_DAY_SELECTION,
            data: data
        });
    },

    togglePeriodSelection: function togglePeriodSelection (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_PERIOD_SELECTION,
            data: data
        });
    },

    togglePeriodsSelection: function togglePeriodsSelection (periods) {
        if (_.isString(periods)) { periods = [periods]; } // Ensure array
        periods = _.map(periods, function(period) {
            var splitted_period = period.split('-');
            return { day: splitted_period[0], period: splitted_period[1] };
        });
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.TOGGLE_PERIODS_SELECTION,
            data: periods
        });
    },

    setTrainingDate: function setTrainingDate (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_TRAINING_DATE,
            data: data
        });
    },

    setTrainingDates: function setTrainingDates (data) {
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_TRAINING_DATES,
            data: data
        });
    },
};
