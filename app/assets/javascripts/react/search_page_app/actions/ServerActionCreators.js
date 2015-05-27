var SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants');
    AlgoliaSearchUtils   = require('../utils/AlgoliaSearchUtils'),
    ActionTypes          = SearchPageConstants.ActionTypes;

module.exports = {
    fetchData: function fetchData (data) {
        SearchPageDispatcher.dispatch({ actionType: ActionTypes.LOAD_PLANNINGS });
        AlgoliaSearchUtils.searchPlannings(data).then(function(content){
            SearchPageDispatcher.dispatch({
                actionType: ActionTypes.LOAD_PLANNINGS_SUCCESS,
                data:       content.hits
            });
        }).catch(function(error) {
            SearchPageDispatcher.dispatch({
                actionType: ActionTypes.LOAD_PLANNINGS_ERROR,
                error:      error
            });
        });

    }
};
