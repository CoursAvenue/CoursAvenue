Rating = React.createClass({
    propTypes: {
        comment_count: React.PropTypes.number.isRequired,
    },

    render: function render () {
        if (this.props.comment_count && this.props.comment_count > 0) {
            var comments = (<span className="v-middle">{this.props.comment_count + ' avis'}</span>);
        } else {
            var comments = (<i className="v-middle">Aucun avis pour le moment</i>);
        }
        return (
          <div className='very-soft--top very-soft'>
              <span className="v-middle">{comments}</span>
          </div>
        );
    },
});

module.exports = Rating;
