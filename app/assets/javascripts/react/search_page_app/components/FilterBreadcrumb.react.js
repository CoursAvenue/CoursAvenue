var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FilterBreadcrumbItem  = require("./FilterBreadcrumbItem"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return { filter_store: FilterStore };
    },

    render: function render () {
        var filters = this.state.filter_store.getFilters().map(function(filter, index) {
            return ( <FilterBreadcrumbItem filter={filter} key={index} /> )
        });
        return (
          <div>
              {filters}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
