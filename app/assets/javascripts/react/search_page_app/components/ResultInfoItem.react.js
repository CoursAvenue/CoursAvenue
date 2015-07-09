var SubjectActionCreators = require('../actions/SubjectActionCreators');

var ResultInfoItem = React.createClass({

    filterSubject: function filterSubject () {
        SubjectActionCreators.selectSubject({ slug: this.props.subject_slug, name: this.props.subject_name });
    },

    componentDidMount: function componentDidMount() {
        $dom_node = $(this.getDOMNode())
        var this_offset_left = $dom_node.offset().left + $dom_node.width()
        var parent_offset_left = $dom_node.parent().offset().left + $dom_node.parent().width()
        if (this_offset_left > parent_offset_left) {
            $(this.getDOMNode()).hide();
        }
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
