var SubjectActionCreators = require('../../actions/SubjectActionCreators'),
    cx                    = require('classnames/dedupe');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
    },

    getInitialState: function getInitialState () {
        return { selected: false };
    },

    // TODO: Send action.
    toggleSelection: function toggleSelection () {
        this.setState({ selected: !this.state.selected });
    },

    render: function render () {
        return (
            <a className="very-soft bg-gray-light black bordered rounded"
               onClick={ this.toggleSelection }>
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
