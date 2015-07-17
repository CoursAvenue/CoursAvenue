var FilterStore                = require('../stores/FilterStore'),
    LocationStore              = require('../stores/LocationStore'),
    SearchPageDispatcher       = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin              = require("../../mixins/FluxBoneMixin"),
    LocationFilterAddressPanel = require('./location_filter_panels/LocationFilterAddressPanel'),
    LocationFilterChoicePanel  = require('./location_filter_panels/LocationFilterChoicePanel'),
    LocationFilterMetroPanel   = require('./location_filter_panels/LocationFilterMetroPanel'),
    classNames                 = require('classnames'),
    FilterPanelConstants       = require('../constants/FilterPanelConstants'),
    FilterActionCreators       = require('../actions/FilterActionCreators'),
    FilterPanelConstants       = require('../constants/FilterPanelConstants');

var LocationFilter = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store: FilterStore,
            location_store: LocationStore
        };
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    panelToShow: function panelToShow () {
        if (this.state.filter_store.get('current_panel') != FilterPanelConstants.FILTER_PANELS.LOCATION) { return; }
        switch(this.state.filter_store.get('location_panel')) {
          case FilterPanelConstants.LOCATION_PANELS.ADDRESS:
            return ( <LocationFilterAddressPanel key='location-metro' /> );
          case FilterPanelConstants.LOCATION_PANELS.METRO:
            return ( <LocationFilterMetroPanel key='location-metro' /> );
          default:
            return ( <LocationFilterChoicePanel key='location-choice' /> );
        }
    },

    title: function title () {
        switch(this.state.filter_store.get('location_panel')) {
          case FilterPanelConstants.LOCATION_PANELS.ADDRESS:
            return "Indiquez une adresse"
          case FilterPanelConstants.LOCATION_PANELS.METRO:
            return "Choisissez une ligne de transports"
          default:
            return "Où souhaitez-vous trouver un cours ?"
        }
    },

    render: function render () {
        var current_panel    = this.state.filter_store.get('current_panel');
        var is_current_panel = current_panel == FilterPanelConstants.FILTER_PANELS.LOCATION;
        var classes = classNames({
            'search-page-filters-wrapper--from-left-to-right': (current_panel == FilterPanelConstants.FILTER_PANELS.TIME || current_panel == FilterPanelConstants.FILTER_PANELS.MORE),
            'search-page-filters-wrapper--from-right-to-left': current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECTS,
            'search-page-filters-wrapper--active': is_current_panel,
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters__location-panel search-page-filters-wrapper'}>
              <div className="search-page-filters__title">
                  {this.title()}
                  <div className="search-page-filters__closer" onClick={this.closeFilterPanel}>
                      <i className="fa fa-times-big"></i>
                  </div>
              </div>
              <div className="search-page-filters__content">
                { this.panelToShow() }
              </div>
          </div>
        );
    }
});

module.exports = LocationFilter;
