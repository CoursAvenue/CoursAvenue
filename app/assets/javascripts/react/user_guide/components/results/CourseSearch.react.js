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
        this.setState({ city: city.replace(', France','').toLowerCase().replace(/ /g,'-').replace(/ème/g,'') });
    },

    getButton: function getButton () {
        if (this.state.city && this.props.subject) {
            return (
                <a className='nowrap btn btn--yellow input--large' href={ this.props.subject.searchUrl(this.state.city) } target='_blank' >
                    <i className='fa-search'></i>
                    Trouver
                </a>
            );
        } else {
            var course_name = '';
            if (this.props.subject) {
                course_name = this.props.subject.get('name');
            }
            return (
                <button disabled className='nowrap btn btn--yellow input--large'>
                    <i className='fa-search'></i>
                    Trouver
                </button>
            );
        }
    },

    render: function render () {
        if (!this.props.subject) { return false; }
        var course_name = this.props.subject.get('name');

        return (
            <div className='grid main-container main-container--medium'>
                <div className='grid__item one-half v-middle palm-one-whole'>
                    <h4 className="palm-text--center white flush text--right">
                            Trouvez le cours de { course_name } idéal à
                    </h4>
                </div>
                <div className='grid__item one-half v-middle palm-one-whole soft-half--left'>
                    <div className='flexbox'>
                        <div className='flexbox__item v-middle search-input-wrapper very-soft hard--ends palm-hard' style={ { width: '140px' } }>
                            <div className='input-with-icon'>
                                <input className='palm-one-whole input--large one-whole soft-half--left' onChange={ this.setCity_ } placeholder='Ville' />
                                <i className='fa-map-marker delta black'></i>
                            </div>
                        </div>
                        <div className='flexbox__item v-middle palm-text--center'>
                            { this.getButton() }
                        </div>
                    </div>
                </div>
            </div>
        );
    },
});

module.exports = CourseSearch;
