Rating = React.createClass({
    propTypes: {
        commentCount: React.PropTypes.number.isRequired,
    },

    render: function render () {
        return (
          <div className='very-soft--top very-soft--bottom'>
              <i className="fa fa-star"></i>
              <i className="fa fa-star"></i>
              <i className="fa fa-star"></i>
              <i className="fa fa-star"></i>
              <i className="fa fa-star"></i>
              ({this.props.comment_count} avis)
          </div>
        );
    },
});

module.exports = Rating;
