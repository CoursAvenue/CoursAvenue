var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var RootSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    filterBySubject: function filterBySubject () {
        SubjectActionCreators.selectRootSubject(this.props.subject.get('slug'));
    },

    render: function render () {
        var subject = this.props.subject.toJSON();
        return (
            <div className="one-sixth very-softf inline-block">
              <div className="bg-white bordered cursor-pointer soft-halff" onClick={this.filterBySubject}>
                  {subject.name}
              </div>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
