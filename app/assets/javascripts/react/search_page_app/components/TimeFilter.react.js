var FilterStore                    = require('../stores/FilterStore'),
    LocationStore                  = require('../stores/LocationStore'),
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
            filter_store: FilterStore,
            location_store: LocationStore
        };
    },

    title: function title () {
        switch(this.state.filter_store.get('time_panel')) {
          case FilterPanelConstants.TIME_PANELS.TRAINING:
              return "Indiquez vos disponibilités";
          case FilterPanelConstants.TIME_PANELS.LESSON:
          default:
              return "Indiquez vos disponibilités";
        }
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
        var classes = classNames({
            'search-page-filters-wrapper--active': (this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters-wrapper search-page-filters__time-panel'}>
              <div className="search-page-filters__title">
                  {this.title()}
                  <div className="search-page-filters__closer" onClick={this.closeFilterPanel}>
                      <i className="fa fa-times beta"></i>
                  </div>
              </div>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = TimeFilter;
