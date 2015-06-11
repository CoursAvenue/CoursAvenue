var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    unFilter: function unFilter () {
        // TODO
    },

    render: function render () {
        return (
          <div onClick={this.unFilter}>
              {this.props.name}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
