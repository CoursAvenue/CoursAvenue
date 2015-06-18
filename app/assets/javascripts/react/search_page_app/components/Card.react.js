var CardActionCreators = require('../actions/CardActionCreators'),
    SubjectList        = require('./cards/SubjectList.react'),
    CourseInformation  = require('./cards/CourseInformation.react'),
    CourseLocation     = require('./cards/CourseLocation.react'),
    Rating             = require('./cards/Rating.react');

Card = React.createClass({

    highlightMaker: function highlightMaker (event) {
        CardActionCreators.highlightMarker({ event: event, card: this.props.card });
    },

    unHighlightMaker: function unHighlightMaker (event) {
        CardActionCreators.unHighlightMarker({ event: event, card: this.props.card });
    },

    render: function render () {
        var gift_classes = { gray: this.props.card.get('is_open_for_trial')}
        return (
          <div className="soft-half one-quarter palm-one-whole lap-one-half inline-block v-top"
              onMouseEnter={ this.highlightMaker } onMouseLeave={ this.unHighlightMaker }>
              <div className="bg-white bordered">
                  <div className="bordered--bottom">
                      <img className="block one-whole" src={this.props.card.get('header_image')} height="100"/>
                  </div>
                  <div className="soft-half">
                      <img className="rounded--circle center-block push-half--bottom"
                            style={{ marginTop: '-35px' }}
                            width="50"
                           src={this.props.card.get('structure_logo_url')} />
                      <div className="text--center">
                          <div className="push-half--bottom gray">
                              <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                                 className="semi-muted-link">
                                  {this.props.card.get('structure_name')}
                              </a>
                          </div>
                          <h4>{this.props.card.get('course_name')}</h4>
                      </div>
                      <SubjectList subjectList={ this.props.card.get('subjects') } />
                      <Rating comment_count={ this.props.card.get('comments_count') }
                              registration_count={ this.props.card.get('registration_count') } />
                      <hr className="push-half--ends" />
                      <CourseInformation courseType={ this.props.card.get('course_type') || ''} weeklyAvailability={ this.props.card.get('weekly_availability') } />
                      <hr className="push-half--ends" />
                      <CourseLocation rankingInfo={ this.props.card.get('_rankingInfo') } address={ this.props.card.get('place_address') } />
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Card;