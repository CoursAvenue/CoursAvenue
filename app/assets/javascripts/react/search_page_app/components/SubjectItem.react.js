var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var RootSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    selectSubject: function selectSubject () {
        SubjectActionCreators.selectSubject(this.props.subject);
    },

    render: function render () {
        return (
            <div className="one-third flexbox__item v-middle search-page-filters__image-button"
                 onClick={this.selectSubject}
                 style={ { backgroundImage: 'url("' + this.props.subject.image_url + '")' } }>
                  <div className="search-page-filters__image-button-curtain"></div>
                  <div className="search-page-filters__image-text">{this.props.subject.name}</div>
            </div>
        );
    }
});

module.exports = RootSubjectItem;
