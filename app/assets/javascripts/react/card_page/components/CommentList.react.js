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
                no_comments = (<p>{"Vous connaissez cet établissement ? Soyez le premier à laisser un avis !"}</p>)
            } else {
                comment_title = this.state.comment_store.total + ' avis';
                comments = this.state.comment_store.map(function(comment, index) {
                    var hr;
                    if (index > 0) { hr = (<hr className="push--ends nine-twelfths margin-left-auto" />); }
                    return (<div key={ index }>
                              {hr}
                              <Comment comment={comment} key={comment.get('id')}/>
                            </div>);
                });
                pagination = (<CommentPagination />)
            }
        }
        return (
            <div>
                <div className="grid--full bg-blue-green bordered--sides bordered--top border-color-blue-green-darker soft--sides soft-half--ends white">
                    <div className="grid__item v-middle one-half">
                        <h2 className="flush">
                            <i className="fa-comment v-middle"></i>&nbsp;
                            <span className="v-middle">{comment_title}</span>
                        </h2>
                    </div>
                    <div className="grid__item v-middle one-half text--right">
                        <a className="btn btn--white-transparent btn--white-transparent--white btn--small" target="_blank"
                           href={Routes.new_structure_comment_path(this.props.structure.slug)}>
                            Déposer mon avis
                        </a>
                    </div>
                </div>
                <div className="bg-white bordered--sides bordered--bottom soft hard--bottom">
                  { spinner }
                  { no_comments }
                  { comments }
                  { pagination }
                </div>
            </div>
        );
    }
});

module.exports = CommentList;
