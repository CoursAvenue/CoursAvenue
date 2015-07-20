var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    SubjectStore          = require('../stores/SubjectStore'),
    CardStore             = require('../stores/CardStore'),
    LocationStore         = require('../stores/LocationStore'),
    TimeStore             = require('../stores/TimeStore'),
    FilterBreadcrumbItem  = require("./FilterBreadcrumbItem"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    mixins: [
        FluxBoneMixin(['card_store', 'subject_store', 'location_store', 'time_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            card_store    : CardStore,
            subject_store : SubjectStore,
            location_store: LocationStore,
            time_store    : TimeStore
        };
    },

    render: function render () {
        var filter_wrapper_class;
        var filters = this.state.card_store.getBreadcrumbFilters().map(function(filter, index) {
            return ( <FilterBreadcrumbItem filter={filter} key={index} /> )
        });
        if (filters.length > 0) {
            filter_wrapper_class = 'search-page-filter-breadcrumb-wrapper soft-half--top'
        }
        return (
          <div className={"main-container main-container--1000 " + filter_wrapper_class}>
              {filters}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
