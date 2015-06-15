var SubjectActionCreators = require('../../actions/SubjectActionCreators'),
    cx                    = require('classnames/dedupe');

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

    // TODO: Send action.
    toggleSelection: function toggleSelection () {
        this.setState({ selected: !this.state.selected });
    },

    render: function render () {
        var classes = cx("inline-block very-soft bg-gray-light black bordered rounded", {
            selected: this.state.selected
        });
        return (
            <a className={ classes }
               onClick={ this.toggleSelection }>
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
