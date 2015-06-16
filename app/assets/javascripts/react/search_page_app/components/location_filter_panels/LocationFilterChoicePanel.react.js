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

    render: function render () {
        return (
          <div className="text--center soft">
              <h2 className="push-half--bottom soft-half--bottom bordered--bottom inline-block">
                  Où ?
              </h2>
              <h3>Où souhaitez vous pratiquer cette activité ?</h3>
              <div className="bordered soft delta cursor-pointer inline-block v-middle push--right"
                   onClick={this.locateUser}>
                  Autour de moi
              </div>
              <div className="bordered soft delta cursor-pointer inline-block v-middle"
                   onClick={this.showAddressPanel}>
                  {"Autour d'une adresse"}
              </div>
          </div>
        );
    }
});

module.exports = LocationFilterChoicePanel;
