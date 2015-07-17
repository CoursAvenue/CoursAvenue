var FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    LocationStore          = require("../stores/LocationStore"),
    CardStore              = require("../stores/CardStore"),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    Map                    = require("./Map.react"),
    cx                     = require('classnames/dedupe'),
    FluxBoneMixin          = require("../../mixins/FluxBoneMixin");

var MapComponent = React.createClass({

    mixins: [
        FluxBoneMixin(['location_store', 'card_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            location_store: LocationStore,
            card_store    : CardStore
        };
    },

    toggleFullScreen: function toggleFullScreen () {
        LocationActionCreators.toggleFullScreen();
    },

    render: function render () {
        var map_style, height_class, expand_button;

        if (this.state.location_store.get('fullscreen')) {
            expand_button = (<span><i className="fa fa-compress"></i>Réduire</span>)
        } else {
            expand_button = (<span><i className="fa fa-expand"></i>Agrandir</span>)
        }
        return (
          <div className={cx("relative overflow-hidden search-page-filters__map-container",
                             { 'search-page-filters__map-container--full': this.state.location_store.get('fullscreen')}) }>
              <div onClick={this.toggleFullScreen} className="search-page-map__fullscreen-button">
                  {expand_button}
              </div>
              <div className={cx("on-top-of-the-world search-page-filters__map-container-curtain absolute north west height-100-percent one-whole on-top flexbox", {
                                 'search-page-filters__map-container-curtain--active': this.state.card_store.loading
                  })}>
                  <div className="flexbox__item v-middle">
                      <div className="spinner">
                          <div className="double-bounce1"></div>
                          <div className="double-bounce2"></div>
                          <div className="double-bounce3"></div>
                      </div>
                  </div>
              </div>
              <Map center={this.props.center} />
          </div>
        );
    }
});

module.exports = MapComponent;
