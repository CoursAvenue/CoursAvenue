var FilterStore                    = require('../stores/FilterStore'),
    SearchPageDispatcher           = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin                  = require("../../mixins/FluxBoneMixin"),
    classNames                     = require('classnames'),
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
        var classes = classNames({
            'north'     : (this.state.filter_store.current_panel == 'locations'),
            'down-north': !(this.state.filter_store.current_panel == 'locations')
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
