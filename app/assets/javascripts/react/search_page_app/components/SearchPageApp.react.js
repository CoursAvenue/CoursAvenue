var MapContainer           = require('./MapContainer.react'),
    SmallMap               = require("./SmallMap.react"),
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
    SearchPageAppRouter    = require('../SearchPageAppRouter'),
    FilterStore            = require('../stores/FilterStore'),
    SubjectStore           = require('../stores/SubjectStore'),
    CardStore              = require('../stores/CardStore'),
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
        CardStore.on('search:done', this.search_page_app_router.updateUrl);

        Backbone.history.start({ pushState: true });
        this.bootsrapData();
        this.search_page_app_router.bootsrapData();
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

            <MapContainer center={this.props.map_center} />
            <SubjectFilter />
            <LocationFilter />
            <TimeFilter />
            <MoreFilter />
            <div className="on-top-of-the-world relative">
                <FilterBar />
                <div className="search-page-content relative">
                    <FilterBreadcrumb />
                    <ResultInfo />
                    <ResultList />
                    <Pagination />
                    <SmallMap center={this.props.map_center} />
                </div>
            </div>
          </div>
        );
    }

});

module.exports = SearchPageApp;
