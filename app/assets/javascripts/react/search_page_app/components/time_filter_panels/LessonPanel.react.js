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
          <div className="flexbox relative">
              <div className="flexbox__item text--center v-middle search-page-filters__panel-height">
                  <div className="search-page-filters__image-button-curtain"></div>
                  <div className="relative">
                      <TimeTable timeTable={ this.state.time_table } />
                      <a onClick={ this.closePanel } className='btn'>Valider</a>
                  </div>
              </div>
          </div>
        );
    },
});

module.exports = LessonPanel;
