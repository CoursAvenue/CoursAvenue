var ReactPropTypes        = React.PropTypes,
    SubjectStore          = require('../stores/SubjectStore'),
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var GroupSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    getInitialState: function getInitialState() {
        return {
            subject_store: SubjectStore,
        };
    },

    filterByGroupSubject: function filterByGroupSubject () {
        SubjectActionCreators.selectGroupSubject(this.props.subject);
    },

    render: function render () {
        var subject = this.props.subject;
        return (
            <div className="one-third flexbox__item v-middle search-page-filters__image-button"
                 onClick={this.filterByGroupSubject}
                 style={ { backgroundImage: 'url("' + subject.image_url + '")' } }>
                <div className="search-page-filters__image-button-curtain">
                </div>
                <div className="search-page-filters__image-text">
                    {subject.name}
                </div>
          </div>
        );
    }
});

module.exports = GroupSubjectItem;
