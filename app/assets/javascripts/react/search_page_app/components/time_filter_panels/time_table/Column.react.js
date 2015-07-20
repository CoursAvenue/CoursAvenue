var Cell               = require('./Cell'),
    TimeActionCreators = require('../../../actions/TimeActionCreators'),
    cx                 = require('classnames/dedupe');

var Column = React.createClass({
    propTypes: {
        day: React.PropTypes.object.isRequired,
        key: React.PropTypes.number
    },

    toggleSelected: function toggleSelected () {
        TimeActionCreators.toggleDaySelection(this.props.day);
    },

    render: function render () {
        var day     = this.props.day;
        var periods = this.props.day.get('periods');
        var cells   = periods.map(function(selected, index) {
            return (
                <Cell selected={ selected } index={ index } key={ index } day={ day } />
            )
        });
        var checked = _.every(periods, _.identity);
        return (
            <div className='grid__item one-seventh'>
                <div className='push--bottom'>
                    { cells }
                </div>
                <div onClick={ this.toggleSelected }
                     className={cx('btn btn-white-to-blue btn--full', { 'btn--active': checked })}>
                     {this.props.day.get('title')}
                </div>

            </div>
        )
    },
});

module.exports = Column;
