Rating = React.createClass({
    propTypes: {
        comment_count: React.PropTypes.number.isRequired,
        registration_count: React.PropTypes.number.isRequired
    },

    render: function render () {
        var dash = '';
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
                                      <i className='v-middle fa fa-user'></i>
                                      <span className="v-middle">&nbsp;{this.props.registration_count}&nbsp;</span>
                                  </span>);
        }
        if (this.props.comment_count && this.props.comment_count > 0) {
            var comments = (<span className="v-middle">{this.props.comment_count + ' avis'}</span>);
        } else {
            var comments = (<i className="v-middle">Aucun avis pour le moment</i>);
        }
        if (registration_count.length > 0) {
            dash = '—';
        }
        return (
          <div className='very-soft--top very-soft'>
              {registration_count}
              {dash}
              <span className="v-middle">{comments}</span>
          </div>
        );
    },
});

module.exports = Rating;
