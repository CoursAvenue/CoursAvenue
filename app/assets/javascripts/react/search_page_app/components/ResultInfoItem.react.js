var SubjectActionCreators = require('../actions/SubjectActionCreators');

var ResultInfoItem = React.createClass({

    filterSubject: function filterSubject () {
        SubjectActionCreators.selectSubject({ slug: this.props.subject_slug, name: this.props.subject_name });
    },

    render: function render () {
      var dash = (this.props.show_dash ? ' - ' : '');
      return (<span>
                  {dash}
                  <a className="semi-muted-link lbl v-middle"
                     href='javascript:void(0)'
                     onClick={this.filterSubject}>
                      {this.props.subject_name} ({this.props.number})
                  </a>
              </span>);
    }
});

module.exports = ResultInfoItem;
