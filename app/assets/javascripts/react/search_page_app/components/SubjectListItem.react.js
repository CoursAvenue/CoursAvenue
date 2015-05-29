var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var SubjectListItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    filterBySubject: function filterBySubject () {
        SubjectActionCreators.selectSubject(this.props.subject.get('slug'));
    },

    render: function render () {
        var subject = this.props.subject.toJSON();
        return (
          <div className="soft bg-white bordered inline-block push-half--right cursor-pointer"
                onClick={this.filterBySubject}>
              {subject.name}
          </div>
        );
    }
});

module.exports = SubjectListItem;
