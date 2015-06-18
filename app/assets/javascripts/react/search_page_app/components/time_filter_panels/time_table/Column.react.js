var Cell = require('./Cell'),
    TimeActionCreators = require('../../../actions/TimeActionCreators');

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
                <div className='soft-half'>{ this.props.day.get('title') }</div>
                { cells }
                <input name={this.props.day.get('name')}
                       className='push-half'
                       type='checkbox'
                       onChange={ this.toggleSelected }
                       checked={ checked } />
            </div>
        )
    },
});

module.exports = Column;
