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
                url: 'https://maps.googleapis.com/maps/api/geocode/json?address=%QUERY&components=country:FR&sensor=false&region=fr&language=fr',
                filter: function filter (parsedResponse) {
                    // query = query + ' France';
                    return _.map(parsedResponse.results, function (result) {
                        // City is a component that has locality in his types
                        var city_component = _.detect(result.address_components, function(address_component) {
                            return (address_component.types.indexOf('locality') !== -1);
                        });
                        return {
                            latitude : result.geometry.location.lat,
                            longitude: result.geometry.location.lng,
                            name     : result.formatted_address,
                            city     : (city_component ? city_component.long_name : 'paris'),
                            zoom     : this.zoomFromGoogleType(result.types[0])
                        };
                    }, this);
                }.bind(this)
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
        $(this.getDOMNode()).find('.tt-input').focus();
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

    zoomFromGoogleType: function zoomFromGoogleType (google_type) {
        // https://developers.google.com/maps/documentation/geocoding/intro#Types
        switch(google_type) {
            case 'street_address'             : return 16; // Done
            case 'route'                      : return 15; // Done
            case 'intersection'               : return 13;
            case 'political'                  : return 13;
            case 'country'                    : return 13;
            case 'administrative_area_level_1': return 13;
            case 'administrative_area_level_2': return 13;
            case 'administrative_area_level_3': return 13;
            case 'administrative_area_level_4': return 13;
            case 'administrative_area_level_5': return 13;
            case 'colloquial_area'            : return 15;
            case 'locality'                   : return 13; // Done
            case 'ward'                       : return 13;
            case 'sublocality'                : return 13;
            case 'sublocality_level_1'        : return 14; // Done
            case 'sublocality_level_2'        : return 13;
            case 'sublocality_level_3'        : return 13;
            case 'sublocality_level_4'        : return 13;
            case 'sublocality_level_5'        : return 13;
            case 'subway_station'             : return 16; // Done
            case 'neighborhood'               : return 15; // Done
            case 'premise'                    : return 13;
            case 'subpremise'                 : return 13;
            case 'postal_code'                : return 13;
            case 'natural_feature'            : return 13;
            case 'airport'                    : return 14; // Done
            case 'park'                       : return 13;
            case 'point_of_interest'          : return 13;
            default                           : return 13;
        }
    },
    render: function render () {
        return (
          <div className="relative">
              <ol className="search-page-filters__breadcrumbs">
                  <li>
                      <a onClick={this.showLocationChoicePanel} className="block text--left">Où</a>
                  </li>
                  <li>{"Autour d'une adresse"}</li>
              </ol>
              <div className="flexbox bg-cover"
                   style={ { backgroundImage: 'url("https://coursavenue-public.s3.amazonaws.com/public_assets/search_page/filter-where-address.jpg")' } }>
                  <div className="flexbox__item text--center v-middle search-page-filters__panel-height input-with-button">
                      <div className="search-page-filters__image-button-curtain"></div>
                      <div className="inline-block v-middle relative center-block text--left">
                          <input className="input--white input--very-large inline-block"
                                 size="40"
                                 onChange={this.searchFullText}
                                 placeholder="Entrez le nom de la localité" />
                      </div>
                      <div className="btn search-page-filters__button btn--yellow v-middle relative"
                           onClick={this.closeFilterPanel}>
                          OK
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = LocationFilterChoicePanel;
