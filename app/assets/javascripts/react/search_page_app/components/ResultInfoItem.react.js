var SubjectActionCreators = require('../actions/SubjectActionCreators');

var ResultInfoItem = React.createClass({

    filterSubject: function filterSubject () {
        SubjectActionCreators.selectSubject({ slug: this.props.subject_slug, name: this.props.subject_name });
    },

    render: function render () {
      return (<span>
                  <a className="semi-muted-link lbl v-middle push-half--right"
                     href='javascript:void(0)'
                     onClick={this.filterSubject}>
                      {this.props.subject_name} ({this.props.number})
                  </a>
              </span>);
    }
});

module.exports = ResultInfoItem;
