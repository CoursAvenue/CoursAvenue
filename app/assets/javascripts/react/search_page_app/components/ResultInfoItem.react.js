var SubjectActionCreators = require('../actions/SubjectActionCreators'),
    LocationStore         = require('../stores/LocationStore'),
    SubjectStore          = require('../stores/SubjectStore');

var ResultInfoItem = React.createClass({

    filterSubject: function filterSubject (event) {
        SubjectActionCreators.selectSubject({ slug: this.props.subject_slug, name: this.props.subject_name });
        event.stopPropagation(); event.preventDefault();
    },

    url: function url () {
        // We return URL ONLY if we know the root slug
        if (SubjectStore.selected_root_subject) {
            return CoursAvenue.searchPath({ city: LocationStore.getCitySlug(),
                                            root_subject_id: SubjectStore.selected_root_subject.slug,
                                            subject_id: this.props.subject_slug });
        } else {
            return 'javascript:void(0)';
        }

    },

    render: function render () {
      return (<a className="nowrap inline-block search-page__result-info"
                 href={this.url()}
                 onClick={this.filterSubject}>
                  {this.props.subject_name}
                  <span className="search-page__result-info-number">{this.props.number}</span>
              </a>);
    }
});

module.exports = ResultInfoItem;
