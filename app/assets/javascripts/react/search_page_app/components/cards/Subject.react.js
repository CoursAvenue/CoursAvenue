var SubjectActionCreators = require('../../actions/SubjectActionCreators'),
    cx                    = require('classnames/dedupe');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
    },

    getInitialState: function getInitialState () {
        return { selected: false };
    },

    toggleSelection: function toggleSelection () {
        console.log('clicked!');
        this.setState({ selected: !this.state.selected });
    },

    render: function render () {
        var classes = cx({
            'caps': true,
            'white': true,
            'selected': this.state.selected,
        });

        console.log(classes);

        return (
            <a className={ classes } onClick={ this.toggleSelection }>
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
