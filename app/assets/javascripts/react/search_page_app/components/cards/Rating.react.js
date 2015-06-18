Rating = React.createClass({
    propTypes: {
        comment_count: React.PropTypes.number.isRequired,
        registration_count: React.PropTypes.number.isRequired
    },

    render: function render () {
        var registration_count = '';
        if (this.props.registration_count > 0) {
            registration_count = (<span>
                                      <i className='fa fa-user'>{this.props.registration_count}</i>
                                  </span>);
        }
        var comments = (this.props.comment_count ? '(' + this.props.comment_count + ' avis)' : '');
        return (
          <div className='very-soft--top very-soft bordered--top'>
              {registration_count}
              {comments}
          </div>
        );
    },
});

module.exports = Rating;
