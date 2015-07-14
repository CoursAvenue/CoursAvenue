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
        var classes = cx('bordered very-soft cursor-pointer text--center white', { 'bg-blue': this.props.selected });
        var cell_content = (this.props.selected ? (<i className="fa fa-check"></i>) : (<span dangerouslySetInnerHTML={{__html: '&nbsp;' }} ></span>));
        return (
            <div onClick={ this.toggleSelected }
                 className={ classes }>
                 {cell_content}
            </div>
        );
    },
});

module.exports = Cell;
