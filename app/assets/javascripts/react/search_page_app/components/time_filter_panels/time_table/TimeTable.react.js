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
            <div className='hard main-container'>
                <div className='grid'>
                    <div className='grid__item one-third text--right'>
                        <div className='very-soft'>&nbsp;</div>
                        <div className='very-soft'>Matin (avant 12h)</div>
                        <div className='very-soft'>Midi (12h-14h)</div>
                        <div className='very-soft'>Après Midi (14h-18h)</div>
                        <div className='very-soft'>Soirée (après 18h)</div>
                        <div className='very-soft'>Toute la journée</div>
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
