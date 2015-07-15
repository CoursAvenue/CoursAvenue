var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators');

var RootSubjectItem = React.createClass({

    propTypes: {
        subject: ReactPropTypes.object
    },

    selectRootSubject: function selectRootSubject () {
        SubjectActionCreators.selectRootSubject(this.props.subject);
    },

    render: function render () {
        return (
          <div className="one-third flexbox__item v-middle search-page-filters__image-button search-page-filters__image-button--with-icon"
               onClick={this.selectRootSubject}
               style={ { backgroundImage: 'url("' + this.props.subject.image_url + '")' } }>
                <div className="search-page-filters__image-button-curtain"></div>
                <div className="search-page-filters__image-icon">
                    <i className="fa fa-danse"></i>
                </div>
                <div className="search-page-filters__image-text">{this.props.subject.name}</div>
          </div>
        );
    }
});

module.exports = RootSubjectItem;
