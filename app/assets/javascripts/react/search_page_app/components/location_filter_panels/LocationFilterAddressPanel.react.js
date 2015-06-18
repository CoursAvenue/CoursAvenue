var FluxBoneMixin          = require("../../../mixins/FluxBoneMixin"),
    LocationActionCreators = require("../../actions/LocationActionCreators"),
    LocationStore          = require("../../stores/LocationStore"),
    FilterActionCreators   = require("../../actions/FilterActionCreators");

var LocationFilterChoicePanel = React.createClass({

    mixins: [
        FluxBoneMixin('location_store')
    ],

    getInitialState: function getInitialState() {
        return {
            location_store: LocationStore
        };
    },

    componentDidMount: function componentDidMount () {
        var template_string = '<p data-lat="{{lat}}" data-lng="{{lng}}" data-city="{{city}}">{{name}}</p>';
        var template = Handlebars.compile(template_string);
        var engine = new Bloodhound({
            datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            remote: {
                url: 'https://maps.googleapis.com/maps/api/geocode/json?address=%QUERY&components=country:FR&sensor=false&region=fr',
                filter: function filter (parsedResponse) {
                    // query = query + ' France';
                    return _.map(parsedResponse.results, function (result) {
                        return {
                            latitude : result.geometry.location.lat,
                            longitude: result.geometry.location.lng,
                            name     : result.formatted_address
                        };
                    });
                }
            }
        });
        engine.initialize();
        var $input = $(this.getDOMNode()).find('input');
        $input.on('typeahead:selected', this.filterByAddress);
        $input.typeahead({
            highlight : true,
            minLength: 1,
            autoselect: true
        }, {
            displayKey: 'name',
            templates: {
                suggestion: template
            },
            source: engine.ttAdapter()
        });
    },

    filterByAddress: function filterByAddress (event, address) {
        address.is_address = true;
        LocationActionCreators.filterByAddress(address);
    },

    showLocationChoicePanel: function showLocationChoicePanel () {
        FilterActionCreators.showLocationChoicePanel();
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    render: function render () {
        return (
          <div>
              <div className="main-container">
                  <ol className="nav breadcrumb text--left">
                      <li>
                          <a onClick={this.showLocationChoicePanel} className="block text--left">Où</a>
                      </li>
                      <li>{"Autour d'une adresse"}</li>
                  </ol>
              </div>
              <h2 className="text--center push-half--bottom soft-half--bottom bordered--bottom inline-block">
                  Indiquez une adresse
              </h2>
              <div>
                  <div className="inline-block v-middle relative center-block text--left">
                      <input className="input--large inline-block"
                             size="50"
                             onChange={this.searchFullText}
                             placeholder="Entrez le nom de la localité" />
                  </div>
                  <div className="btn v-middle" onClick={this.closeFilterPanel}>OK</div>
              </div>
          </div>
        );
    }
});

module.exports = LocationFilterChoicePanel;
