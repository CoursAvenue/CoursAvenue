var Comment               = require('./Comment'),
    CommentPagination     = require('./CommentPagination'),
    CommentActionCreators = require("../actions/CommentActionCreators"),
    CommentStore          = require('../stores/CommentStore');

var CommentList = React.createClass({

    mixins: [
        FluxBoneMixin('comment_store')
    ],

    componentDidMount: function componentDidMount() {
        CommentActionCreators.setStructureSlug(this.props.structure_slug)
    },

    getInitialState: function getInitialState() {
        return { comment_store: CommentStore };
    },

    render: function render () {
        var spinner, comments, no_comments, pagination, comment_title;
        if (this.state.comment_store.loading) {
            var spinner = (<div className="spinner">
                              <div className="double-bounce1"></div>
                              <div className="double-bounce2"></div>
                              <div className="double-bounce3"></div>
                          </div>);
        } else {
            if (this.state.comment_store.isEmpty()) {
                comment_title = 'Avis';
                no_comments = (<div>{"Pas d'avis sur ce cours."}</div>)
            } else {
                comment_title = this.state.comment_store.total + ' avis';
                comments = this.state.comment_store.map(function(comment) {
                    return (<Comment comment={comment} key={comment.get('id')}/>);
                });
                pagination = (<CommentPagination />)
            }
        }
        return (
            <div>
                <h3>{comment_title}</h3>
                { spinner }
                { no_comments }
                { comments }
                { pagination }
            </div>
        );
    }
});

module.exports = CommentList;
