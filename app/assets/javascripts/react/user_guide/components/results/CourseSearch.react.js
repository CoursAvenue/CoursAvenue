var CourseSearch = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    getInitialState: function getInitialState () {
        return { searchURL: null, city: null };
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
                        // City is a component that has locality in his types
                        var city_component = _.detect(result.address_components, function(address_component) {
                            return (address_component.types.indexOf('locality') !== -1);
                        });
                        return {
                            latitude : result.geometry.location.lat,
                            longitude: result.geometry.location.lng,
                            name     : result.formatted_address,
                            city     : (city_component ? city_component.long_name : 'paris')
                        };
                    });
                }
            }
        });
        engine.initialize();
        var $input = $(this.getDOMNode()).find('input');
        $input.on('typeahead:selected', this.setCity);
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

    // http://stackoverflow.com/a/24849854/1814139
    setCity: function setCity (event, address) {
        var city = address.city;
        this.setState({ city: city });
    },

    getButton: function getButton () {
        if (this.state.city && this.props.subject) {
            return (
                <a className='btn btn--white two-twelfths' href={ this.props.subject.searchUrl() } target='_blank' >
                    Trouver un cours de { this.props.subject.get('name') }
                </a>
            );
        } else {
            var course_name = '';
            if (this.props.subject) {
                course_name = this.props.subject.get('name');
            }
            return (
                <button disabled className='btn btn--white two-twelfths'>Trouver un cours de { course_name }</button>
            );
        }
    },

    render: function render () {
        return (
            <div className='grid'>
                <div className='grid__item ten-twelfths'>
                    <input className="input--very-large inline-block"
                         size="40"
                         onChange={ this.setCity_ }
                         placeholder="Entrez le nom de la localité" />
                 </div>
                 { this.getButton() }
            </div>
        );
    },
});

module.exports = CourseSearch;
