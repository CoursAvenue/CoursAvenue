var FluxBoneMixin        = require("../../../mixins/FluxBoneMixin"),
    MetroStopStore       = require('../../stores/MetroStopStore'),
    FilterActionCreators = require("../../actions/FilterActionCreators");

var LocationFilterMetroPanel = React.createClass({
    mixins: [
        FluxBoneMixin('metro_stop_store')
    ],

    getInitialState: function getInitialState () {
        return {
            metro_stop_store: MetroStopStore,
        };
    },

    showLocationChoicePanel: function showLocationChoicePanel () {
        FilterActionCreators.showLocationChoicePanel();
    },

    closeFilterPanel: function closeFilterPanel () {
    },

    changeLine: function changeLine () {
        debugger
    },

    render: function render () {
        var metro_stops = _.map([], function(stop, index) {
            return (
                <div>stop.name</div>
            );
        });

        return (
            <div>
              <div className='main-container'>
                <ol className="nav breadcrumb text--left">
                  <li>
                    <a onClick={ this.showLocationChoicePanel } className="block text--left">Où</a>
                  </li>
                  <li>{"Proche d'un Métro"}</li>
                </ol>
              </div>
              <h2 className="text--center push-half--bottom soft-half--bottom bordered--bottom inline-block">
                Choisissez une ligne et une station
              </h2>
              <div>
                <div className="inline-block v-middle relative center-block text--left">
                  <select onChange={ this.changeLine }>
                      { metro_stops }
                  </select>
                </div>

                <div className="inline-block v-middle relative center-block text--left">
                  <input className="input--large inline-block"
                         size="50"
                         placeholder="Entrez le nom de la localité" />
                </div>
                <div className="btn v-middle" onClick={this.closeFilterPanel}>OK</div>
              </div>
            </div>
        );
    },
});

module.exports = LocationFilterMetroPanel;
