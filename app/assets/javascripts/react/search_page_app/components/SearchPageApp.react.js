var MapContainer              = require('./MapContainer.react'),
    SmallMap                  = require("./SmallMap.react"),
    ResultList                = require('./ResultList.react'),
    SubjectFilter             = require('./SubjectFilter.react'),
    SubjectAutocompleteFilter = require('./SubjectAutocompleteFilter.react'),
    LocationFilter            = require('./LocationFilter.react'),
    TimeFilter                = require('./TimeFilter.react'),
    MoreFilter                = require('./MoreFilter.react'),
    FilterBar                 = require('./FilterBar.react'),
    FilterBreadcrumb          = require('./FilterBreadcrumb.react'),
    ResultInfo                = require('./ResultInfo.react'),
    ResultSorting             = require('./ResultSorting.react'),
    Pagination                = require('./Pagination.react'),
    Menubar                   = require('./Menubar.react'),
    SearchPageAppRouter       = require('../SearchPageAppRouter'),
    FilterStore               = require('../stores/FilterStore'),
    SubjectStore              = require('../stores/SubjectStore'),
    CardStore                 = require('../stores/CardStore'),
    UserStore                 = require('../stores/UserStore'),
    LocationStore             = require('../stores/LocationStore'),
    SearchPageDispatcher      = require('../dispatcher/SearchPageDispatcher'),
    SearchPageConstants       = require('../constants/SearchPageConstants'),
    FilterActionCreators      = require('../actions/FilterActionCreators'),
    SubjectActionCreators     = require('../actions/SubjectActionCreators'),
    LocationActionCreators    = require('../actions/LocationActionCreators'),
    CardActionCreators        = require('../actions/CardActionCreators');

SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
    },

    /*
     * Initialization
     */
    componentWillMount: function componentWillMount() {
        this.search_page_app_router = this.search_page_app_router || new SearchPageAppRouter();
	CardStore.on('search:done', this.search_page_app_router.updateUrl);
	CardStore.on('page:change', this.search_page_app_router.updateUrl);

	// CardStore.setFavorites(this.props.favorite_cards);
	UserStore.setFavorites(this.props.favorite_cards);
	if (this.props.logged_in) { UserStore.log_in(); }

	Backbone.history.start({ pushState: true });
	this.search_page_app_router.bootsrapData();
    },

    componentDidMount: function componentDidMount() {
        if (this.props.show_subject_panel) {
            FilterActionCreators.toggleSubjectFilter();
        }
        // We have to trigger this action on when the app is mounted because the action is triggered
        // by a component
        if (this.props.locate_user) {
            LocationActionCreators.locateUser();
        }
    },


    render: function render() {
        return (
          <div className="relative on-top">
              <div className="relative overflow-hidden">
                  <Menubar />

                  <MapContainer center={this.props.map_center} />

                  <SubjectAutocompleteFilter />
                  <SubjectFilter />
                  <LocationFilter />
                  <TimeFilter />
                  <MoreFilter />
              </div>
              <div className="on-top-of-the-world search-page-content relative">
                  <div className="main-container main-container--1000">
                      <FilterBar />
                      <FilterBreadcrumb />
                      <ResultInfo />
                      <ResultList address={this.props.address}
                                  root_subject={this.props.root_subject}
                                  subject={this.props.subject}/>
                      <Pagination />
                  </div>
                  <SmallMap center={this.props.map_center} />
              </div>
          </div>
        );
    }

});

module.exports = SearchPageApp;
