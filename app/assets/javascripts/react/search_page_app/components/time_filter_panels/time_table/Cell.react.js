var cx = require('classnames/dedupe');

var Cell = React.createClass({
    propTypes: {
        day: React.PropTypes.object.isRequired,
        selected: React.PropTypes.bool.isRequired,
    },

    getInitialState: function getInitialState () {
        return { selected: this.props.selected };
    },

    toggleSelected: function toggleSelected () {
        console.log('ACTION: toggleCell');
        this.setState({ selected: !this.state.selected });
    },

    render: function render () {
        var classes = cx('bordered cursor-pointer', { selected: this.state.selected });
        return (
            <div onClick={ this.toggleSelected } className={ classes } style={ { height: '15px' } }></div>
        );
    },
});

module.exports = Cell;
