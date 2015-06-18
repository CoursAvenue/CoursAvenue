var Column        = require('./Column'),
    TimeStore     = require("../../../stores/TimeStore"),
    FluxBoneMixin = require("../../../../mixins/FluxBoneMixin");

var TimeTable = React.createClass({

    mixins: [
        FluxBoneMixin('time_store')
    ],

    getInitialState: function getInitialState() {
        return { time_store: TimeStore };
    },

    propTypes: {
        timeTable: React.PropTypes.object.isRequired,
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
                    <div className='grid__item one-third text--right'>
                        <div className='soft-half'>&nbsp;</div>
                        <div className='soft-half'>Matin (avant 12h)</div>
                        <div className='soft-half'>Midi (12h-14h)</div>
                        <div className='soft-half'>Après Midi (14h-18h)</div>
                        <div className='soft-half'>Soirée (après 18h)</div>
                        <div className='soft-half'>Toute la journée</div>
                    </div>
                    <div className='grid__item two-thirds'>
                        <div className='grid'>
                            { columns }
                        </div>
                    </div>
                </div>
            </div>
        );
    }
});

module.exports = TimeTable;
