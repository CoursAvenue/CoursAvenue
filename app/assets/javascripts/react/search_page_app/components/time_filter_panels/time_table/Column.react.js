var Cell = require('./Cell');

var Column = React.createClass({
    propTypes: {
        day: React.PropTypes.object.isRequired,
        key: React.PropTypes.number
    },

    toggleSelected: function toggleSelected () {
        console.log('ACTION: toggledayselection');
    },

    render: function render () {
        var day = this.props.day;
        var cells = this.props.day.get('periods').map(function(selected, index) {
            return (
                <Cell selected={ selected } key={ index } day={ day } />
            )
        });
        return (
            <div className='grid__item one-seventh'>
                <div className=''>{ this.props.day.get('title') }</div>
                { cells }
                <input type='checkbox' onClick={ this.toggleSelected } />
            </div>
        )
    },
});

module.exports = Column;
