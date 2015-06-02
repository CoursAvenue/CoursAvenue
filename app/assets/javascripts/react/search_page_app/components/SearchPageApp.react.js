var Map                  = require('./Map.react'),
    ResultList           = require('./ResultList.react'),
    SubjectFilter        = require('./SubjectFilter.react'),
    FilterBar            = require('./FilterBar.react'),
    SearchPageAppRouter  = require('../SearchPageAppRouter'),
    PlanningStore        = require('../stores/PlanningStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants  = require('../constants/SearchPageConstants'),
    FilterActionCreators = require('../actions/FilterActionCreators');

SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
    },

    /*
     * Initialization
     */
    componentDidMount: function componentDidMount() {
        this.search_page_app_router = this.search_page_app_router || new SearchPageAppRouter();
        FilterStore.on('change', this.search_page_app_router.updateUrl);

        Backbone.history.start({ pushState: true });

        var data =  {};
        _.each(this.props.filters, function(value, key) {
            data[key] = (_.isString(value) ? $.parseJSON(value) : value);
        });
        FilterActionCreators.updateFilters(data);
    },

    render: function render() {
        return (
          <div className="relative">
            <Map center={this.props.map_center} />
            <SubjectFilter />
            <FilterBar />
            <ResultList />
          </div>
        );
    }

});

module.exports = SearchPageApp;
