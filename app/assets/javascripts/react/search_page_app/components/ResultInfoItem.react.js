var SubjectActionCreators = require('../actions/SubjectActionCreators');

var ResultInfoItem = React.createClass({

    filterSubject: function filterSubject () {
        SubjectActionCreators.selectSubject({ slug: this.props.subject_slug, name: this.props.subject_name });
    },

    render: function render () {
      return (<a className="nowrap inline-block search-page__result-info"
                 href='javascript:void(0)'
                 onClick={this.filterSubject}>
                  {this.props.subject_name}
                  <span className="search-page__result-info-number">{this.props.number}</span>
              </a>);
    }
});

module.exports = ResultInfoItem;
