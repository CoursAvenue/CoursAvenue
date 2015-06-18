var FilterStore                = require('../stores/FilterStore'),
    SearchPageDispatcher       = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin              = require("../../mixins/FluxBoneMixin"),
    LocationFilterAddressPanel = require('./location_filter_panels/LocationFilterAddressPanel'),
    LocationFilterChoicePanel  = require('./location_filter_panels/LocationFilterChoicePanel'),
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
            filter_store: FilterStore
        };
    },

    panelToShow: function panelToShow () {
        switch(this.state.filter_store.get('location_panel')) {
          case FilterPanelConstants.LOCATION_PANELS.ADDRESS:
            return ( <LocationFilterAddressPanel/> );
          // case FilterPanelConstants.LOCATION_PANELS.METRO:
          //   return ( <LocationFilterMetroPanel key='root' /> );
          default:
            return ( <LocationFilterChoicePanel/> );
        }
    },

    render: function render () {
        var isCurrentPanel = this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION;
        var classes = classNames({
            'north'     : isCurrentPanel,
            'down-north': !isCurrentPanel
        });
        return (
          <div className={classes + ' on-top transition-all-300 absolute west one-whole bg-white height-35vh text--center'}
               style={{ minHeight: '230px'}}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = LocationFilter;
