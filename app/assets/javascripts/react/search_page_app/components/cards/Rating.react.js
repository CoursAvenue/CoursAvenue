Rating = React.createClass({
    propTypes: {
        comment_count: React.PropTypes.number.isRequired,
        registration_count: React.PropTypes.number.isRequired
    },

    render: function render () {
        if (this.props.registration_count > 1) {
            var tooltip_content = this.props.registration_count + " utilisateurs se sont inscrits à ce cours";
        } else {
            var tooltip_content = this.props.registration_count + " utilisateur s'est inscrit à ce cours";
        }
        var registration_count = '';
        if (this.props.registration_count > 0) {
            registration_count = (<span data-toggle='tooltip'
                                        data-trigger="hover"
                                        data-placement="top"
                                        data-title={tooltip_content}>
                                      <i className='fa fa-user'>{this.props.registration_count}</i>
                                  </span>);
        }
        var comments = (this.props.comment_count ? '(' + this.props.comment_count + ' avis)' : '');
        return (
          <div className='very-soft--top very-soft'>
              {registration_count}
              {comments}
          </div>
        );
    },
});

module.exports = Rating;
