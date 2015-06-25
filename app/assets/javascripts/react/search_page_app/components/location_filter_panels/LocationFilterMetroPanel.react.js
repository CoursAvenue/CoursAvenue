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
        FilterActionCreators.closeFilterPanel();
    },

    selectLine: function selectLine (event) {
        var line = event.target.value;
        FilterActionCreators.selectMetroLine(line);
    },

    selectStop: function selectStop (event) {
        var stop = event.target.value;
        FilterActionCreators.selectMetroStop(stop);
    },

    componentDidMount: function componentDidMount () {
        // TODO: Remove this.
        FilterActionCreators.selectMetroLine('ligne-8');
    },

    render: function render () {
        var metro_stops = this.state.metro_stop_store.map(function(stop, index) {
            return (
                <option key={ index } value={ stop.get('slug') }>{ stop.get('name') }</option>
            );
        });

        // TODO: Temporary, store in a MetroLineStore ?
        var metro_lines = _.map(this.state.metro_stop_store.metroLines(), function(line, index) {
            return (
                <option key={ index } value={ line.slug }>{ line.name }</option>
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
                Choisissez une ligne et/ou une station
              </h2>
              <div>
                <div className="inline-block v-middle relative center-block text--left">
                  <select onChange={ this.selectLine }>
                      { metro_lines }
                  </select>
                </div>

                <div className="inline-block v-middle relative center-block text--left">
                  <select onChange={ this.selectStop }>
                  <option disabled selected></option>
                      { metro_stops }
                  </select>
                </div>

                <div className="btn v-middle" onClick={this.closeFilterPanel}>OK</div>
              </div>
            </div>
        );
    },
});

module.exports = LocationFilterMetroPanel;
