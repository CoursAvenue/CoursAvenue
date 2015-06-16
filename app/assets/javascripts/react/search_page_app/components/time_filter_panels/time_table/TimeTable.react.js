var Column = require('./Column');

var TimeTable = React.createClass({

    propTypes: {
        timeTable: React.PropTypes.object.isRequired,
    },

    setFilters: function setFilters () {
        console.log('TODO: Send action with filter');
    },

    render: function render () {
        var columns = this.props.timeTable.map(function(day, index) {
            return (
                <Column day={ day } key={ index } />
            )
        });

        return (
            <div className='main-container'>
                <div className='grid'>
                    <div className='grid__item one-third'>
                    </div>
                    <div className='grid__item two-thirds'>
                        <div className='grid'>
                            { columns }
                        </div>
                    </div>
                </div>

                <a onClick={ this.setFilters } className='btn'>Valider</a>
            </div>
        );
    }
});

module.exports = TimeTable;
