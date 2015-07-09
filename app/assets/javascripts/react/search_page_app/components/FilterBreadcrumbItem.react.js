var ReactPropTypes        = React.PropTypes,
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    unsetFilter: function unsetFilter () {
        FilterActionCreators.unsetFilter(this.props.filter.filter_key)
    },

    showFilterPanel: function showFilterPanel () {
        switch(this.props.filter.type) {
          case 'subject':
              FilterActionCreators.toggleSubjectFilter();
              break;
          case 'location':
              FilterActionCreators.toggleLocationFilter();
              break;
          case 'time':
              FilterActionCreators.toggleTimeFilter();
              break;
        }
    },

    render: function render () {
        return (
          <div className={"search-page-filter-breadcrumb search-page-filter-breadcrumb--" + this.props.filter.type}>
              <span onClick={this.showFilterPanel} className="v-middle">{this.props.filter.title}</span>
              <i className="fa fa-times cursor-pointer v-middle" onClick={this.unsetFilter}></i>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
