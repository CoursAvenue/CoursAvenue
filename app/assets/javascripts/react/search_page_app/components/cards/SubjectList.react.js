var _       = require('lodash'),
    Subject = require('./Subject.react');

Subject_list = React.createClass({
    propTypes: {
        subject_list: React.PropTypes.array.isRequired
    },

    componentDidMount: function componentDidMount () {
        var that = this;
        $(this.getDOMNode()).dotdotdot({
            ellipsis : '... ',
            wrap     : 'children',
            tolerance: 3,
            callback : function callback (is_truncated, original_content) {
                if (is_truncated) {
                    var $dot_node = $('<div></div>').addClass('search-page-card__subject');
                    $dot_node.addClass('search-page__result-info--dot-dot-dot nowrap');
                    $dot_node.addClass('search-page-card__subject--' + that.props.subject_list[0].root_slug);
                    $dot_node.append($('<i class="fa fa-circle"></i>'));
                    $dot_node.append($('<i class="fa fa-circle"></i>'));
                    $dot_node.append($('<i class="fa fa-circle"></i>'));
                    $dot_node.attr('data-toggle', 'popover')
                             .attr('data-placement', 'top')
                             .attr('data-content', _.map(original_content, function(a) {return $(a).text()}).join(', '));
                    $(this).append($dot_node);
                }
            }
        });
    },

    render: function render () {
        if (_.isEmpty(this.props.subject_list)) {
            return false;
        }

        var subject_nodes = _.map(this.props.subject_list, function(subject, index) {
            return (
                <Subject colored={this.props.colored}
                         follow_links={this.props.follow_links}
                         subject={ subject } key={ index } />
            );
        }, this);

        return (
            <div className={"search-page-card__subjects-wrapper " + (this.props.classes ? this.props.classes : '')}>
                { subject_nodes }
            </div>
        )
    },
});

module.exports = Subject_list;
