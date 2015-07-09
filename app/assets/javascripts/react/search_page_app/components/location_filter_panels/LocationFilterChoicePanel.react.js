var FluxBoneMixin          = require("../../../mixins/FluxBoneMixin"),
    LocationActionCreators = require("../../actions/LocationActionCreators"),
    FilterActionCreators   = require("../../actions/FilterActionCreators");

var LocationFilterChoicePanel = React.createClass({

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
          <div className="text--center soft">
              <div className="search-page-filters__title">
                  Où souhaitez-vous trouver un cours ?
              </div>
              <div className="bordered bg-white soft delta cursor-pointer inline-block v-middle push--right"
                   onClick={this.locateUser}>
                  Autour de moi
              </div>
              <div className="bordered bg-white soft delta cursor-pointer inline-block v-middle"
                   onClick={this.showAddressPanel}>
                  {"Autour d'une adresse"}
              </div>
              <div className="bordered bg-white soft delta cursor-pointer inline-block v-middle push--left"
                   onClick={ this.showMetroPanel }>
                  {"Proche d'un métro"}
              </div>
          </div>
        );
    }
});

module.exports = LocationFilterChoicePanel;
