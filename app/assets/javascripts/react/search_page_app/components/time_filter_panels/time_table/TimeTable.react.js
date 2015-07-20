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
                    <div className='flexbox__item soft--right nowrap text--right white'>
                        <div>
                            <span className="search-page-time-panel__left-cell">Matin</span>
                            <span className="search-page-time-panel__left-cell--blue">(avant 12h)</span>
                        </div>
                        <div>
                            <span className="search-page-time-panel__left-cell">Midi</span>
                            <span className="search-page-time-panel__left-cell--blue">(12h-14h)</span>
                        </div>
                        <div>
                            <span className="search-page-time-panel__left-cell">Après-Midi</span>
                            <span className="search-page-time-panel__left-cell--blue">(14h-18h)</span>
                        </div>
                        <div className='push--bottom '>
                            <span className="search-page-time-panel__left-cell">Soirée</span>
                            <span className="search-page-time-panel__left-cell--blue">(après 18h)</span>
                        </div>
                        <div>
                            <span className="search-page-time-panel__left-cell">Toute la journée</span>
                        </div>
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
