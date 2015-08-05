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

    /*
     * @start_date 1437688800 Date as Unix timestamp
     */
    setTrainingStartDate: function setTrainingStartDate (start_date) {
        start_date = parseInt(start_date, 10); // Ensure it is an Integer
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_TRAINING_START_DATE,
            data: start_date
        });
    },

    /*
     * @end_date 1437688800 Date as Unix timestamp
     */
    setTrainingEndDate: function setTrainingEndDate (end_date) {
        end_date = parseInt(end_date, 10); // Ensure it is an Integer
        SearchPageDispatcher.dispatch({
            actionType: ActionTypes.SET_TRAINING_END_DATE,
            data: end_date
        });
    },
};
