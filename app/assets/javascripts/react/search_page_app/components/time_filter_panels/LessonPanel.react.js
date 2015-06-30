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
        return (
          <div>
              <div className="search-page-filters__title">Indiquez vos disponibilités</div>

              <TimeTable timeTable={ this.state.time_table } />
              <a onClick={ this.closePanel } className='btn'>Valider</a>
          </div>
        );
    },
});

module.exports = LessonPanel;