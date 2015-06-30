var FluxBoneMixin        = require("../../../mixins/FluxBoneMixin"),
    MetroLineStore       = require('../../stores/MetroLineStore'),
    MetroStopStore       = require('../../stores/MetroStopStore'),
    MetroLineChip        = require('../../../components/MetroLineChip.react'),
    FilterActionCreators = require("../../actions/FilterActionCreators");

var LocationFilterMetroPanel = React.createClass({
    mixins: [
        FluxBoneMixin(['metro_stop_store', 'metro_line_store'])
    ],

    getInitialState: function getInitialState () {
        return {
            metro_stop_store: MetroStopStore,
            metro_line_store: MetroLineStore,
        };
    },

    showLocationChoicePanel: function showLocationChoicePanel () {
        FilterActionCreators.showLocationChoicePanel();
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    selectLine: function selectLine (line) {
        return function() {
            FilterActionCreators.selectMetroLine(line);
        }
    },

    selectStop: function selectStop (event) {
        var stop = event.target.value;
        FilterActionCreators.selectMetroStop(stop);
    },

    componentDidMount: function componentDidMount () {
        FilterActionCreators.selectMetroLine('ligne-1');
    },

    render: function render () {
        var metro_stops = this.state.metro_stop_store.map(function(stop, index) {
            return (
                <option key={ index } value={ stop.get('slug') }>{ stop.get('name') }</option>
            );
        });

        // TODO: Temporary, store in a MetroLineStore ?
        var metro_lines = this.state.metro_line_store.map(function(line, index) {
            return (
                <div onClick={ this.selectLine(line.get('slug')) } key={ index }
                      className="inline-block v-middle"
                      style={ { paddingRight: '4px' } }>
                      <MetroLineChip line={line.toJSON()}/>
                </div>
            );
        }.bind(this));

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
              <div className="search-page-filters__title">
                Choisissez une ligne et/ou une station
              </div>
              <div>
                <div className="push-half--bottom center-block text--center">
                  { metro_lines }
                </div>

                <div className="inline-block v-middle relative center-block text--left">
                  <select defaultValue='none' onChange={ this.selectStop }>
                  <option value='none'></option>
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
