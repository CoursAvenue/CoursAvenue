var CommentStore             = require('../stores/CommentStore'),
    CommentActionCreators    = require("../actions/CommentActionCreators"),
    FluxBoneMixin            = require("../../mixins/FluxBoneMixin"),
    Pagination               = require("../../mixins/Pagination");

var CommentPagination = React.createClass({

    mixins: [
        FluxBoneMixin('comment_store'),
        Pagination('comment_store', CommentActionCreators)
    ],

    getInitialState: function getInitialState() {
        return { comment_store: CommentStore };
    }
});

module.exports = CommentPagination;
