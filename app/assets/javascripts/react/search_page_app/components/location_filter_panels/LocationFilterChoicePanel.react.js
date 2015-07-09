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

    render: function render () {
        return (
          <div className="flexbox">
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button", {
                    'search-page-filters__image-button--active': this.state.location_store.isUserLocated()
                  }) }
                   onClick={this.locateUser}
                   style={ { backgroundImage: 'url("https://coursavenue-public.s3.amazonaws.com/public_assets/search_page/filter-where-around-me.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <div className="search-page-filters__image-text">Autour de moi</div>
              </div>
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button", {
                    'search-page-filters__image-button--active': this.state.location_store.isFilteredByAddress()
                  }) }
                   onClick={this.showAddressPanel}
                   style={ { backgroundImage: 'url("https://coursavenue-public.s3.amazonaws.com/public_assets/search_page/filter-where-address.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <div className="search-page-filters__image-text">{"Autour d'une adresse"}</div>
              </div>
              <div className={cx("one-third flexbox__item v-middle search-page-filters__image-button", {
                    'search-page-filters__image-button--active': this.state.metro_store.getSelectedLines().length > 1
                  }) }
                   onClick={ this.showMetroPanel }
                   style={ { backgroundImage: 'url("https://coursavenue-public.s3.amazonaws.com/public_assets/search_page/filter-where-metro.jpg")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <div className="search-page-filters__image-text">{"Proche d'un métro"}</div>
              </div>
          </div>
        );
    }
});
module.exports = LocationFilterChoicePanel;