var _       = require('lodash'),
    Subject = require('./Subject.react');

SubjectList = React.createClass({
    propTypes: {
        subjectList: React.PropTypes.array.isRequired
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
                    $dot_node.addClass('search-page__result-info--dot-dot-dot');
                    $dot_node.addClass('search-page-card__subject--' + that.props.subjectList[0].root_slug);
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
        if (_.isEmpty(this.props.subjectList)) {
            return false;
        }

        var subjectNodes = this.props.subjectList.map(function(subject, index) {
            return (
                <Subject subject={ subject } key={ index } />
            );
        });

        return (
            <div>
                { subjectNodes }
            </div>
        )
    },
});

module.exports = SubjectList;
