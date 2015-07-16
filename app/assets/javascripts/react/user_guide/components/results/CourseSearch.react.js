var CourseSearch = React.createClass({
    propTypes: {
        subject: React.PropTypes.object,
    },

    getInitialState: function getInitialState () {
        return { searchURL: null };
    },

    componentDidUpdate: function componentDidUpdate () {
        $(this.getDOMNode()).find('[data-behavior=city-autocomplete]').cityAutocomplete();
    },

    // TODO: This doesn't fucking work.
    updateUrl: function updateUrl (event) {
        event.preventDefaul();
        var city = event.trigger;
        this.setState({ searchURL: Routes.city_subject_path(city, this.props.subject.slug) });
    },

    render: function render () {
        if (!this.props.subject) { return false; }
        return (
            <div className='text--center'>
                <input autoComplete='off' placeholder='Code Postal' data-behavior='city-autocomplete' data-el='#subject_search_city'></input>
                <select id='subject_search_city' placeholder='Ville' onChange={ this.updateUrl }></select>
                <a className='disabled btn' href={ this.state.searchURL }>Trouver un cours de { this.props.subject.get('name') }</a>
            </div>
        );
    },
});

module.exports = CourseSearch;
