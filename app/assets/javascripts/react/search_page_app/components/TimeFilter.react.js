var FilterStore                    = require('../stores/FilterStore'),
    SearchPageDispatcher           = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin                  = require("../../mixins/FluxBoneMixin"),
    classNames                     = require('classnames'),
    FilterActionCreators           = require('../actions/FilterActionCreators'),
    FilterPanelConstants           = require('../constants/FilterPanelConstants'),
    LessonPanel                    = require('./time_filter_panels/LessonPanel'),
    TrainingPanel                  = require('./time_filter_panels/TrainingPanel');

var TimeFilter = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store:  FilterStore
        };
    },

    panelToShow: function panelToShow () {
        switch(this.state.filter_store.get('time_panel')) {
          case FilterPanelConstants.TIME_PANELS.TRAINING:
              return (<TrainingPanel />);
          case FilterPanelConstants.TIME_PANELS.LESSON:
          default:
              return (<LessonPanel />);
        }
    },

    render: function render () {
        var isCurrentPanel = this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME;
        var classes = classNames({
            'north'     : isCurrentPanel,
            'down-north': !isCurrentPanel
        });
        return (
          <div className={ classes + ' transition-all-300 absolute west one-whole bg-white height-35vh text--center' }
               style={{ minHeight: '230px'}}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = TimeFilter;
