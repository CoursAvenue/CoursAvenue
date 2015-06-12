var ReactPropTypes        = React.PropTypes,
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    unsetFilter: function unsetFilter () {
        FilterActionCreators.unsetFilter(this.props.filter.filter_key)
    },

    render: function render () {
        return (
          <div className="inline-block bordered push-half--right very-soft bg-gray-light">
              {this.props.filter.title}
              <i className="fa fa-times cursor-pointer" onClick={this.unsetFilter}></i>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
