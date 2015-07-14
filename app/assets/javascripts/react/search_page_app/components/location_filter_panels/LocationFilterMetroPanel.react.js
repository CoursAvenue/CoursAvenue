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

    render: function render () {
        var metro_stops = this.state.metro_stop_store.map(function(stop, index) {
            return (
                <option key={ index } value={ stop.get('slug') }>{ stop.get('name') }</option>
            );
        });

        // TODO: Temporary, store in a MetroLineStore ?
        var metro_lines = this.state.metro_line_store.where({ line_type: 'metro' }).map(function(line, index) {
            return (
                <div onClick={ this.selectLine(line.get('slug')) } key={ index }
                      className="inline-block v-middle"
                      style={ { marginRight: '4px' } }>
                      <MetroLineChip line={line.toJSON()}/>
                </div>
            );
        }.bind(this));
        var tramway_lines = this.state.metro_line_store.where({ line_type: 'tramway' }).map(function(line, index) {
            return (
                <div onClick={ this.selectLine(line.get('slug')) } key={ index }
                      className="inline-block v-middle"
                      style={ { marginRight: '4px' } }>
                      <MetroLineChip line={line.toJSON()}/>
                </div>
            );
        }.bind(this));
        var rer_lines = this.state.metro_line_store.where({ line_type: 'rer' }).map(function(line, index) {
            return (
                <div onClick={ this.selectLine(line.get('slug')) } key={ index }
                      className="inline-block v-middle"
                      style={ { marginRight: '4px' } }>
                      <MetroLineChip line={line.toJSON()}/>
                </div>
            );
        }.bind(this));

        return (
            <div className="relative">
                <ol className="search-page-filters__breadcrumbs">
                    <li>
                        <a onClick={ this.showLocationChoicePanel } className="block">Où</a>
                    </li>
                    <li>{"Près d'une station de métro"}</li>
                </ol>
                <div className="flexbox bg-cover"
                     style={ { backgroundImage: 'url("https://coursavenue-public.s3.amazonaws.com/public_assets/search_page/filter-where-metro.jpg")' } }>
                    <div className="flexbox__item v-middle search-page-filters__panel-height input-with-button">
                        <div className="search-page-filters__image-button-curtain"></div>
                        <div className="relative main-container main-container--1000">
                            <div className="push-half--bottom">
                                <div className="metro-line metro-line-m"
                                     style={ { marginRight: '8px' } }>M</div>
                                { metro_lines }
                            </div>
                            <div className="push-half--bottom">
                                <div className="inline-block v-middle">
                                    <div className="metro-line rer-line-rer"
                                         style={ { marginRight: '8px' } }>RER</div>
                                    { rer_lines }
                                </div>
                                <div className="inline-block v-middle">
                                    <div className="metro-line tramway-line-t"
                                         style={ { marginRight: '8px' } }>T</div>
                                    { tramway_lines }
                                </div>
                            </div>

                            <div className="inline-block v-middle relative center-block">
                              <select defaultValue='none' onChange={ this.selectStop }>
                                  <option value='none'></option>
                                  { metro_stops }
                              </select>
                              <div className="btn btn--yellow search-page-filters__button v-middle" onClick={this.closeFilterPanel}>Valider</div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = LocationFilterMetroPanel;
