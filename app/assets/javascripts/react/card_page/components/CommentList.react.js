var Comment               = require('./Comment'),
    CommentPagination     = require('./CommentPagination'),
    StructureActionCreators = require("../actions/StructureActionCreators"),
    CommentStore          = require('../stores/CommentStore');

var CommentList = React.createClass({

    mixins: [
        FluxBoneMixin('comment_store')
    ],

    componentDidMount: function componentDidMount() {
        StructureActionCreators.setStructure(this.props.structure);
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
                comments = this.state.comment_store.map(function(comment, index) {
                    var hr;
                    if (index > 0) { hr = (<hr className="push--ends nine-twelfths margin-left-auto" />); }
                    return (<div>
                              {hr}
                              <Comment comment={comment} key={comment.get('id')}/>
                            </div>);
                });
                pagination = (<CommentPagination />)
            }
        }
        return (
            <div>
                <a className="float--right btn btn--white btn--small" target="_blank"
                   href={Routes.new_structure_comment_path(this.props.structure.slug)}>
                    Déposer mon avis
                </a>
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
