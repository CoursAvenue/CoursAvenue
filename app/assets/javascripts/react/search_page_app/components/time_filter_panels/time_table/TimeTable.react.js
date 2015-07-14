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
                <div className='flexbox'>
                    <div className='flexbox__item nowrap text--right white'>
                        <div className='very-soft'>
                            <strong>Matin</strong> <span>(avant 12h)</span>
                        </div>
                        <div className='very-soft'>
                            <strong>Midi</strong> <span>(12h-14h)</span>
                        </div>
                        <div className='very-soft'>
                            <strong>Après-Midi</strong> <span>(14h-18h)</span>
                        </div>
                        <div className='very-soft push--bottom'>
                            <strong>Soirée</strong> <span>(après 18h)</span>
                        </div>
                        <div className='very-soft'>Toute la journée</div>
                    </div>
                    <div className='flexbox__item'>
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
