var FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    LocationStore          = require("../stores/LocationStore"),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    Map                    = require("./Map.react"),
    cx                     = require('classnames/dedupe'),
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
        if (LocationStore.get('fullscreen')) {
            expand_button = (<span><i className="fa fa-compress"></i>Réduire</span>)
        } else {
            expand_button = (<span><i className="fa fa-expand"></i>Agrandir</span>)
        }
        return (
          <div className={cx("relative overflow-hidden search-page-filters-wrapper",
                             { 'search-page-filters-wrapper--full': LocationStore.get('fullscreen')}) }>
              <div onClick={this.toggleFullScreen} className="search-page-map__fullscreen-button">
                  {expand_button}
              </div>
              <Map center={this.props.center} />
          </div>
        );
    }
});

module.exports = MapComponent;
