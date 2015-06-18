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
        var filters = this.state.card_store.getBreadcrumbFilters().map(function(filter, index) {
            return ( <FilterBreadcrumbItem filter={filter} key={index} /> )
        });
        return (
          <div className="very-soft main-container bg-white ">
              {filters}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
