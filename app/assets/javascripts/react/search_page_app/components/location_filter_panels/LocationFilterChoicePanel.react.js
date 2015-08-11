var FluxBoneMixin          = require("../../../mixins/FluxBoneMixin"),
    LocationActionCreators = require("../../actions/LocationActionCreators"),
    LocationStore          = require("../../stores/LocationStore"),
    MetroLineStore         = require("../../stores/MetroLineStore"),
    cx                     = require('classnames/dedupe'),
    FilterActionCreators   = require("../../actions/FilterActionCreators");

var LocationFilterChoicePanel = React.createClass({
    mixins: [
        FluxBoneMixin(['location_store', 'metro_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            location_store: LocationStore,
            metro_store   : MetroLineStore
        };
    },

    locateUser: function locateUser () {
        LocationActionCreators.locateUser();
    },

    showAddressPanel: function showAddressPanel () {
        FilterActionCreators.showAddressPanel();
    },

    showMetroPanel: function showMetroPanel () {
        FilterActionCreators.showMetroPanel();
    },

    // We show the metro panel only if we are near paris
    shouldShowMetroPanel: function shouldShowMetroPanel () {
        var paris_center = L.latLng(48.8592, 2.3417) // Center of paris
        if (LocationStore.get('bounds')) {
            var location_latlng = L.latLngBounds(LocationStore.get('bounds')).getCenter();
        } else if (LocationStore.get('address')) {
            var location_latlng = L.latLng(LocationStore.get('address').latitude, LocationStore.get('address').longitude);
        }
        if (location_latlng) {
            return location_latlng.distanceTo(paris_center) < 10000; // 10km — seems fair
        }
    },

    render: function render () {
        return (
          <div className="flexbox search-page-filters__panel-height">
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button search-page-filters__image-button--with-icon", {
                    'search-page-filters__image-button--active': this.state.location_store.isUserLocated()
                  }) }
                   onClick={this.locateUser}
                   style={ { backgroundImage: 'url("https://dqggv9zcmarb3.cloudfront.net/assets/search-page-app/filter-where-around-me.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <i className="search-page-filters__image-icon fa fa-around-me"></i>
                  <div className="search-page-filters__image-text">Autour de moi</div>
              </div>
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button search-page-filters__image-button--with-icon", {
                    'search-page-filters__image-button--active': this.state.location_store.isFilteredByAddress()
                  }) }
                   onClick={this.showAddressPanel}
                   style={ { backgroundImage: 'url("https://dqggv9zcmarb3.cloudfront.net/assets/search-page-app/filter-where-address.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <i className="search-page-filters__image-icon fa fa-address"></i>
                  <div className="search-page-filters__image-text">{"Autour d'une adresse"}</div>
              </div>
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button search-page-filters__image-button--with-icon", {
                    'search-page-filters__image-button--active': this.state.metro_store.getSelectedLines().length > 0,
                    'hidden': !this.shouldShowMetroPanel()
                  }) }
                   onClick={ this.showMetroPanel }
                   style={ { backgroundImage: 'url("https://dqggv9zcmarb3.cloudfront.net/assets/search-page-app/filter-where-metro.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <i className="search-page-filters__image-icon fa fa-metro"></i>
                  <div className="search-page-filters__image-text">{"Près d'une station de métro"}</div>
              </div>
          </div>
        );
    }
});
module.exports = LocationFilterChoicePanel;
