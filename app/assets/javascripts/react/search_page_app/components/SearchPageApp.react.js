var Map                   = require('./Map.react'),
    ResultList            = require('./ResultList.react'),
    SubjectFilter         = require('./SubjectFilter.react'),
    FilterBar             = require('./FilterBar.react'),
    FilterBreadcrumb      = require('./FilterBreadcrumb.react'),
    ResultInfo            = require('./ResultInfo.react'),
    SearchPageAppRouter   = require('../SearchPageAppRouter'),
    PlanningStore         = require('../stores/PlanningStore'),
    FilterStore           = require('../stores/FilterStore'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants   = require('../constants/SearchPageConstants'),
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    CityActionCreators    = require('../actions/CityActionCreators');

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
        this.bootsrapData();
    },

    // Bootstraping data
    bootsrapData: function bootsrapData() {
        CityActionCreators.selectCity($.parseJSON(this.props.city));
        if (this.props.root_subject) {
            SubjectActionCreators.selectRootSubject($.parseJSON(this.props.root_subject));
        }
        if (this.props.subject) {
            SubjectActionCreators.selectSubject($.parseJSON(this.props.subject));
        }
    },

    render: function render() {
        return (
          <div className="relative">
            <Map center={this.props.map_center} />
            <SubjectFilter />
            <FilterBar />
            <FilterBreadcrumb />
            <ResultInfo />
            <ResultList />
          </div>
        );
    }

});

module.exports = SearchPageApp;
