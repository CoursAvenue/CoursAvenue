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
        var classes = cx('btn-with-hidden-icon btn btn-white-to-blue btn--full', { 'btn--active': this.props.selected });
        return (
            <div onClick={ this.toggleSelected }
                 className={ classes }
                 style={ { marginBottom: '-2px' } }>
                 <i className="fa fa-check"></i>
            </div>
        );
    },
});

module.exports = Cell;
