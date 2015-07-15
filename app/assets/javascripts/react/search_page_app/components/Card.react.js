var SubjectList        = require('./cards/SubjectList.react'),
    CourseInformation  = require('./cards/CourseInformation.react'),
    CourseLocation     = require('./cards/CourseLocation.react'),
    CardActionCreators = require("../actions/CardActionCreators"),
    Rating             = require('./cards/Rating.react');

Card = React.createClass({

    componentDidMount: function componentDidMount () {
        // TODO: Fix this...
        $(this.getDOMNode()).find('.search-page-card__course-title, .search-page-card__structure-name').dotdotdot({
            ellipsis : '... ',
            wrap     : 'letter',
            tolerance: 3,
            callback : function callback (is_truncated, original_content) {
                if (is_truncated) {
                    $(this).attr('data-toggle', 'popover')
                           .attr('data-html', 'true')
                           .attr('data-placement', 'top')
                           .attr('data-content', '<div class="f-weight-normal f-size-12">' + original_content.text() + '<div>');
                }
            }
        });
    },

    onMouseEnter: function onMouseEnter () {
        CardActionCreators.cardHovered({ card: this.props.card, hovered: true });
    },

    onMouseLeave: function onMouseLeave () {
        CardActionCreators.cardHovered({ card: this.props.card, hovered: false });
    },

    render: function render () {
        var course_information, starting_price, starting_price_class, price,
            gift_classes = { gray: this.props.card.get('is_open_for_trial')}
        if (this.props.card.get('has_course')) {
            if (this.props.card.get('card_type') == 'course') {
                starting_price = (this.props.card.get('starting_price') == 0 ? 'Essai gratuit' : 'Essai à ' + this.props.card.get('starting_price') + '€');
            } else {
                starting_price = (this.props.card.get('starting_price') == 0 ? 'Essai gratuit' : 'Atelier à ' + this.props.card.get('starting_price') + '€');
            }
            starting_price_class = (this.props.card.get('starting_price') == 0 ? 'search-page-card__price--free' : '')
            price = (<div className={'search-page-card__price ' + starting_price_class}>{starting_price}</div>);
        }
        var course_url =  '';
        if (this.props.card.get('slug')) {
            course_url = Routes.structure_indexable_card_path(this.props.card.get('structure_slug'), this.props.card.get('slug'));
        }
        if (this.props.card.get('has_course')) {
            course_information = (<CourseInformation courseType={ this.props.card.get('course_type') || ''} weeklyAvailability={ this.props.card.get('weekly_availability') }
                                  trainings={ this.props.card.get('trainings') } />)
        }
        return (
          <div onMouseEnter={this.onMouseEnter} onMouseLeave={this.onMouseLeave} className="search-page-card soft-half one-quarter palm-one-whole lap-one-half inline-block v-top">
              <div className="search-page-card__number">{this.props.index}.</div>
              <div className="bg-white bordered search-page-card__content">
                  <div className="bordered--bottom relative">
                      {price}
                      <img className="search-page-card__image" src={this.props.card.get('header_image')} />
                  </div>
                  <div className="soft-half">
                      <img className="search-page-card__structure-logo"
                           src={this.props.card.get('structure_logo_url')} />
                      <div className="text--center">
                          <div className="push-half--bottom gray">
                              <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                                 className="semi-muted-link search-page-card__structure-name">
                                  {this.props.card.get('structure_name')}
                              </a>
                          </div>
                          <h4 className="flush">
                              <a className="search-page-card__course-title semi-muted-link" href={course_url}>
                                  {this.props.card.get('course_name')}
                              </a>
                          </h4>
                      </div>
                      <SubjectList subjectList={ this.props.card.get('subjects') } />
                      <div className="search-page-card__bottom-information">
                          <Rating comment_count={ this.props.card.get('comments_count') } />
                          {course_information}
                          <CourseLocation card={this.props.card} rankingInfo={ this.props.card.get('_rankingInfo') } address={ this.props.card.get('place_address') } />
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Card;
