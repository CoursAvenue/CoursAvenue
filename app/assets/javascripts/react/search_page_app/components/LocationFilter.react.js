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

    panelToShow: function panelToShow () {
        switch(this.state.filter_store.get('location_panel')) {
          case FilterPanelConstants.LOCATION_PANELS.ADDRESS:
            return ( <LocationFilterAddressPanel/> );
          case FilterPanelConstants.LOCATION_PANELS.METRO:
            return ( <LocationFilterMetroPanel key='root' /> );
          default:
            return ( <LocationFilterChoicePanel/> );
        }
    },

    render: function render () {
        var isCurrentPanel = this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION;
        var classes = classNames({
            'north'     : isCurrentPanel,
            'down-north': !isCurrentPanel,
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' on-top transition-all-300 absolute west one-whole bg-white text--center search-page-filters-wrapper'}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = LocationFilter;
