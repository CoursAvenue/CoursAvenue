var SubjectActionCreators = require('../../actions/SubjectActionCreators'),
    LocationStore         = require('../../stores/LocationStore');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
        selected: React.PropTypes.bool
    },

    componentDidMount: function componentDidMount () {
        $(this.getDOMNode()).dotdotdot({
            ellipsis : '... ',
            wrap     : 'letter',
            tolerance: 3,
            callback : function callback (is_truncated, original_content) {
                if (is_truncated) {
                    $(this).attr('data-toggle', 'popover')
                             .attr('data-placement', 'top')
                             .attr('data-content', original_content.text());
                }
            }
        });
    },

    getDefaultProps: function getDefaultProps () {
        return { selected: false };
    },

    getInitialState: function getInitialState () {
        return { selected: this.props.selected };
    },

    selectSubject: function selectSubject (event) {
        SubjectActionCreators.selectSubject(this.props.subject);
        if(!this.props.follow_links) { event.stopPropagation(); event.preventDefault(); }
    },

    url: function url () {
        return CoursAvenue.searchPath({ city: LocationStore.getCitySlug(),
                                        root_subject_id: this.props.subject.root_slug,
                                        subject_id: this.props.subject.slug });
    },

    render: function render () {
        var additionnal_class = '';
        if (this.props.colored) {
          additionnal_class = ' white bg-' + this.props.subject.root_slug;
        }
        return (
            <a className={"hide-for-fout search-page-card__subject search-page-card__subject--" + this.props.subject.root_slug + additionnal_class}
               onClick={ this.selectSubject }
               target={this.props.follow_links ? '_blank' : ''}
               href={this.url()}>
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
