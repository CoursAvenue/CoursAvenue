var MapContainer           = require('./MapContainer.react'),
    ResultList             = require('./ResultList.react'),
    SubjectFilter          = require('./SubjectFilter.react'),
    LocationFilter         = require('./LocationFilter.react'),
    TimeFilter             = require('./TimeFilter.react'),
    MoreFilter             = require('./MoreFilter.react'),
    FilterBar              = require('./FilterBar.react'),
    FilterBreadcrumb       = require('./FilterBreadcrumb.react'),
    ResultInfo             = require('./ResultInfo.react'),
    ResultSorting          = require('./ResultSorting.react'),
    Pagination             = require('./Pagination.react'),
    Menubar                = require('./Menubar.react'),
    SubjectSearchInput     = require('./SubjectSearchInput.react'),
    SearchPageAppRouter    = require('../SearchPageAppRouter'),
    FilterStore            = require('../stores/FilterStore'),
    SubjectStore           = require('../stores/SubjectStore'),
    LocationStore          = require('../stores/LocationStore'),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants    = require('../constants/SearchPageConstants'),
    SubjectActionCreators  = require('../actions/SubjectActionCreators'),
    LocationActionCreators = require('../actions/LocationActionCreators');

SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
    },

    /*
     * Initialization
     */
    componentDidMount: function componentDidMount() {
        this.search_page_app_router = this.search_page_app_router || new SearchPageAppRouter();
        LocationStore.on('change', this.search_page_app_router.updateUrl);
        SubjectStore.on('change', this.search_page_app_router.updateUrl);

        Backbone.history.start({ pushState: true });
        this.bootsrapData();
    },

    // Bootstraping data
    bootsrapData: function bootsrapData() {
        LocationActionCreators.filterByAddress($.parseJSON(this.props.address));
        if (this.props.root_subject) {
            SubjectActionCreators.selectRootSubject($.parseJSON(this.props.root_subject));
        }
        if (this.props.subject) {
            SubjectActionCreators.selectSubject($.parseJSON(this.props.subject));
        }
    },

    render: function render() {
        return (
          <div className="relative overflow-hidden">
            <Menubar />
            <SubjectSearchInput />
            <div className="relative">
              <MapContainer center={this.props.map_center} />
              <SubjectFilter />
              <LocationFilter />
              <TimeFilter />
              <MoreFilter />
            </div>
            <FilterBar />
            <FilterBreadcrumb />
            <ResultInfo />
            <ResultList />
            <Pagination />
          </div>
        );
    }

});

module.exports = SearchPageApp;