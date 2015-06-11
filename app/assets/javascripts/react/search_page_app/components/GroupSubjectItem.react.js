var ReactPropTypes        = React.PropTypes,
    SubjectStore          = require('../stores/SubjectStore'),
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var GroupSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    getInitialState: function getInitialState() {
        return {
            subject_store: SubjectStore,
        };
    },

    filterByGroupSubject: function filterByGroupSubject () {
        SubjectActionCreators.selectGroupSubject(this.props.subject);
    },

    render: function render () {
        var subject = this.props.subject;
        return (
            <div className="one-sixth very-softf inline-block">
              <div className="bg-white bordered cursor-pointer soft-halff" onClick={this.filterByGroupSubject}>
                  {subject.name}
              </div>
          </div>
        );
    }
});

module.exports = GroupSubjectItem;
