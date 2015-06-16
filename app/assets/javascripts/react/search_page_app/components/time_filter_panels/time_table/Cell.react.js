var cx                 = require('classnames/dedupe'),
    TimeActionCreators = require('../../../actions/TimeActionCreators');

var Cell = React.createClass({
    propTypes: {
        day: React.PropTypes.object.isRequired,
        selected: React.PropTypes.bool.isRequired,
        index: React.PropTypes.number.isRequired,
    },

    toggleSelected: function toggleSelected () {
        var data = { day: this.props.day, period: this.props.index };
        TimeActionCreators.togglePeriodSelection(data);
    },

    render: function render () {
        var classes = cx('bordered cursor-pointer', { 'bg-gray': this.props.selected });
        return (
            <div onClick={ this.toggleSelected } className={ classes } style={ { height: '15px' } }></div>
        );
    },
});

module.exports = Cell;
