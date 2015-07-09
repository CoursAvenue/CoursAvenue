var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var RootSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    selectRootSubject: function selectRootSubject () {
        SubjectActionCreators.selectRootSubject(this.props.subject);
    },

    render: function render () {
        return (
          <div className="one-sixth very-softf inline-block">
              <div className="soft delta bg-white bordered cursor-pointer" onClick={this.selectRootSubject}>
                  { this.props.subject.name }
              </div>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
