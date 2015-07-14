var TimeTable            = require('./time_table/TimeTable'),
    TimeStore            = require('../../stores/TimeStore'),
    FilterActionCreators = require('../../actions/FilterActionCreators'),
    FluxBoneMixin        = require('../../../mixins/FluxBoneMixin');

var LessonPanel = React.createClass({

    mixins: [
        FluxBoneMixin('time_table')
    ],

    getInitialState: function getInitialState () {
        return { time_table: TimeStore };
    },

    closePanel: function closePanel () {
        FilterActionCreators.toggleTimeFilter();
    },

    render: function render () {
        return (<div>
                    <div className="push--bottom">
                        <TimeTable timeTable={ this.state.time_table } />
                    </div>
                    <div className="text--center">
                        <a onClick={ this.closePanel } className='btn btn--blue search-page-filters__button'>Ok</a>
                    </div>
                </div>
        );
    },
});

module.exports = LessonPanel;
