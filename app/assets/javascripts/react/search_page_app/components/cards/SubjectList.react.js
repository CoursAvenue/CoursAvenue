var _       = require('underscore'),
    Subject = require('./Subject.react');

SubjectList = React.createClass({
    propTypes: {
        subjectList: React.PropTypes.array.isRequired
    },

    componentDidMount: function componentDidMount () {
        // TODO: Fix this
        // $(this.getDOMNode()).dotdotdot({
        //     ellipsis : '... ',
        //     wrap     : 'children',
        //     tolerance: 3,
        //     callback : function callback (isTruncated, orgContent) {
        //         if (isTruncated) {
        //             var $dot_node = $('<div>...</div>').addClass('search-page-card__subject');
        //             $dot_node.attr('data-toggle', 'popover')
        //                      .attr('data-placement', 'top')
        //                      .attr('data-content', _.map(orgContent, function(a) {return $(a).text()}).join(', '));
        //             $(this).append($dot_node);
        //         }
        //     }
        // });
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
            <div className="search-page-card__subjects-wrapper">
                { subjectNodes }
            </div>
        )
    },
});

module.exports = SubjectList;
