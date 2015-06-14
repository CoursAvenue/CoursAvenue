var SubjectActionCreators = require('../../actions/SubjectActionCreators'),
    cx                    = require('classnames/dedupe');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
        selected: React.PropTypes.boolean
    },

    getDefaultProps: function () {
        return { selected: false };
    },

    getInitialState: function getInitialState () {
        return { selected: this.props.selected };
    },

    // TODO: Send action.
    toggleSelection: function toggleSelection () {
        this.setState({ selected: !this.state.selected });
    },

    render: function render () {
        return (
            <a className="inline-block very-soft bg-gray-light black bordered rounded"
               onClick={ this.toggleSelection }>
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
