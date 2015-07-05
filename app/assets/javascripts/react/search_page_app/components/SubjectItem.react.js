var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var RootSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    selectSubject: function selectSubject () {
        SubjectActionCreators.selectSubject(this.props.subject);
    },

    render: function render () {
        return (
            <div className="one-sixth very-softf inline-block">
                <div className="soft bg-white bordered cursor-pointer" onClick={this.selectSubject}>
                    { this.props.subject.name }
                </div>
            </div>
        );
    }
});

module.exports = RootSubjectItem;