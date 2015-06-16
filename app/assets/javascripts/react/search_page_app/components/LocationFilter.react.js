var FilterStore                    = require('../stores/FilterStore'),
    SearchPageDispatcher           = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin                  = require("../../mixins/FluxBoneMixin"),
    classNames                     = require('classnames'),
    FilterPanelConstants           = require('../constants/FilterPanelConstants'),
    FilterActionCreators           = require('../actions/FilterActionCreators');

var LocationFilter = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store:  FilterStore
        };
    },

    panelToShow: function panelToShow () {
        return (<div> Coucou ! </div>)
    //     switch(this.state.filter_store.get('subject_panel')) {
    //       case 'group':
    //         return ( <LocationFilterGroupSubjectPanel key='group' /> );
    //       case 'root':
    //         return ( <LocationFilterRootSubjectPanel key='root' /> );
    //       case 'child':
    //         return ( <LocationFilterChildSubjectPanel key='child' /> );
    //       default:
    //         return ( <LocationFilterGroupSubjectPanel key='group' /> );
    //     }
    },

    render: function render () {
        var isCurrentPanel = this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION;
        var classes = classNames({
            'north'     : isCurrentPanel,
            'down-north': !isCurrentPanel
        });
        return (
          <div className={classes + ' transition-all-300 absolute west one-whole bg-white height-35vh text--center'}
               style={{ minHeight: '230px'}}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = LocationFilter;
