var SubjectActionCreators = require('../../actions/SubjectActionCreators');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
        selected: React.PropTypes.bool
    },

    getDefaultProps: function () {
        return { selected: false };
    },

    getInitialState: function getInitialState () {
        return { selected: this.props.selected };
    },

    toggleSelection: function toggleSelection () {
        SubjectActionCreators.selectSubject(this.props.subject);
    },

    render: function render () {
        return (
            <a className="inline-block very-soft bg-gray-light black bordered rounded"
               onClick={ this.toggleSelection }
               href="javascript:void(0)">
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
