Rating = React.createClass({
    propTypes: {
        comment_count: React.PropTypes.number.isRequired,
    },

    render: function render () {
        if (this.props.comment_count && this.props.comment_count > 0) {
            var comments = (<span className="v-middle">{this.props.comment_count + ' avis'}</span>);
        } else {
            var comments = (<span className="v-middle f-style-italic">Aucun avis pour le moment</span>);
        }
        return (
          <div className="search-page-card__content-bottom-line">
              <i className="fa fa-user v-middle"></i>
              {comments}
          </div>
        );
    },
});

module.exports = Rating;
