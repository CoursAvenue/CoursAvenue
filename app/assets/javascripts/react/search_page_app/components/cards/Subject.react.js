var SubjectActionCreators = require('../../actions/SubjectActionCreators');

Subject = React.createClass({
    propTypes: {
        subject: React.PropTypes.object.isRequired,
        selected: React.PropTypes.bool
    },

    componentDidMount: function componentDidMount () {
        $(this.getDOMNode()).dotdotdot({
            ellipsis: '... ',
            wrap    : 'letter',
            callback: function callback (isTruncated, orgContent) {
                if (isTruncated) {
                    $(this).attr('data-toggle', 'popover')
                           .attr('data-placement', 'top')
                           .attr('data-content', orgContent.text());
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

    toggleSelection: function toggleSelection () {
        SubjectActionCreators.selectSubject(this.props.subject);
    },

    render: function render () {
        return (
            <a className="search-page-card__subject"
               onClick={ this.toggleSelection }
               href="javascript:void(0)">
                { this.props.subject.name }
            </a>
        )
    },
});

module.exports = Subject;
