var MarkerPopup = React.createClass({

    propTypes: {
        card: React.PropTypes.object.isRequired,
    },

    render: function render () {
        return (
          <div className="bg-white bordered" style={{ maxHeight: '300px', width: '300px' }}>
              <div className="bordered--bottom">
                  <img className="block one-whole" src={this.props.card.get('header_image')} height="100"/>
              </div>
              <div className="soft-half">
                  <img className="rounded--circle push-half--bottom push--left"
                        style={{ marginTop: '-35px' }}
                        width="50"
                       src={this.props.card.get('structure_logo_url')} />
                  <div className="bordered--bottom">
                      <div className="push-half--bottom gray">
                          <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                             className="semi-muted-link">
                              {this.props.card.get('structure_name')}
                          </a>
                      </div>
                      <h4 className="flush">{this.props.card.get('course_name')}</h4>
                  </div>
                  <Rating comment_count={ this.props.card.get('comments_count') }
                          registration_count={ this.props.card.get('registration_count') } />
              </div>
          </div>
        );
    }
});

module.exports = MarkerPopup;
