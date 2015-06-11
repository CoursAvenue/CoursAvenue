var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    propTypes: {
        title:    React.PropTypes.string,
        key_name: React.PropTypes.string
    },

    unFilter: function unFilter () {
        // TODO
    },

    render: function render () {
        return (
          <div className="inline-block bordered push-half--right very-soft bg-gray-light">
              {this.props.filter.title}
              <i className="fa fa-times" onClick={this.unFilter}></i>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
