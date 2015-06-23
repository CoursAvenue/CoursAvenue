var FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    CardStore              = require("../stores/CardStore"),
    LocationStore          = require("../stores/LocationStore"),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    Map                    = require("./Map.react"),
    CardActionCreators     = require("../actions/CardActionCreators"),
    FilterActionCreators   = require("../actions/FilterActionCreators"),
    FluxBoneMixin          = require("../../mixins/FluxBoneMixin");

var MapComponent = React.createClass({

    mixins: [
        FluxBoneMixin('location_store')
    ],

    getInitialState: function getInitialState() {
        return { location_store: LocationStore };
    },

    toggleFullScreen: function toggleFullScreen () {
        LocationActionCreators.toggleFullScreen();
    },

    render: function render () {
        var map_style, height_class, expand_button;
        map_style = {
            minHeight: '230px'
        };
        height_class = (LocationStore.get('fullscreen') ? 'height-70-vh' : 'height-35vh')
        if (LocationStore.get('fullscreen')) {
            expand_button = (<span><i className="fa fa-compress"></i>&nbsp;Réduire la carte</span>)
        } else {
            expand_button = (<span><i className="fa fa-expand"></i>&nbsp;Plein écran</span>)
        }
        return (
          <div className={height_class + " relative overflow-hidden"}>
              <div onClick={this.toggleFullScreen} className="btn btn--small push absolute north east on-top">
                  {expand_button}
              </div>
              <Map center={this.props.center} />
          </div>
        );
    }
});

module.exports = MapComponent;
