var SubjectList        = require('./cards/SubjectList.react'),
    CourseInformation  = require('./cards/CourseInformation.react'),
    CourseLocation     = require('./cards/CourseLocation.react'),
    CardActionCreators = require("../actions/CardActionCreators"),
    Rating             = require('./cards/Rating.react');

Card = React.createClass({

    componentDidMount: function componentDidMount () {
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
        if (this.props.is_popup) { return; }
        CardActionCreators.cardHovered({ card: this.props.card, hovered: true });
    },

    onMouseLeave: function onMouseLeave () {
        if (this.props.is_popup) { return; }
        CardActionCreators.cardHovered({ card: this.props.card, hovered: false });
    },

    headerImage: function headerImage () {
        if (this.props.card.get('header_image')) {
            return (<img className="search-page-card__image" src={this.props.card.get('header_image')} />);
        } else {
            return (<div className={"text--center search-page-card__image bg-" + this.props.card.get('root_subject')}>
                        <i className={'fa-' + this.props.card.get('root_subject')}></i>
                    </div>);
        }
    },

    headerLogo: function headerLogo () {
        if (this.props.card.get('has_course')) {
            if (this.props.card.get('structure_logo_url')) {
                return (<img className="search-page-card__structure-logo" src={this.props.card.get('structure_logo_url')} />);
            } else {
                return (<div className={"search-page-card__structure-logo white text--center bg-" + this.props.card.get('root_subject')}>
                          <i className="fa fa-user-big"></i>
                        </div>);
            }
        } else {
            if (this.props.card.get('structure_logo_large_url')) {
                return (<img className="search-page-card__structure-logo--sleeping" src={this.props.card.get('structure_logo_large_url')} />);
            } else {
                var class_names = "search-page-card__structure-sleeping-logo-icon ";
                class_names    += this.props.card.get('root_subject') + '-color ';
                class_names    += 'fa-' + this.props.card.get('root_subject');
                return (<i className={class_names}></i>);
            }
        }
    },

    headerCard: function headerCard () {
        var starting_price, starting_price_class, price;
        if (this.props.card.get('has_course')) {
            if (this.props.card.get('card_type') == 'course') {
                starting_price = (this.props.card.get('starting_price') == 0 ? 'Essai gratuit' : 'Essai à ' + this.props.card.get('starting_price') + '€');
            } else {
                starting_price = (this.props.card.get('starting_price') == 0 ? 'Essai gratuit' : 'Atelier à ' + this.props.card.get('starting_price') + '€');
            }
            starting_price_class = (this.props.card.get('starting_price') == 0 ? 'search-page-card__price--free' : '')
            price = (<div className={'search-page-card__price ' + starting_price_class}>{starting_price}</div>);

            return (<div>
                        <div className="search-page-card__content-top">
                            <div className="relative">
                                {price}
                                {this.headerImage()}
                            </div>
                            {this.headerLogo()}
                            <div className="search-page-card__structure-name soft-half--sides gray">
                                <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                                   className="semi-muted-link search-page-card__structure-name">
                                    {this.props.card.get('structure_name')}
                                </a>
                            </div>
                        </div>
                        <h4 className="flush text--center soft-half--sides">
                            {this.cardName()}
                        </h4>
                    </div>);
        } else {
            return (<div className="relative">
                        <div className="search-page-card__content-top search-page-card__content-top--sleeping text--center">
                            {this.headerLogo()}
                        </div>
                        <h4 className="flush text--center soft-half--sides">
                            {this.cardName()}
                        </h4>
                    </div>);

        }
    },

    cardName: function cardName () {
        var url =  '';
        if (this.props.card.get('has_course')) {
            url = Routes.structure_indexable_card_path(this.props.card.get('structure_slug'), this.props.card.get('slug'));
            return (<a className={this.props.card.get('root_subject') + "-color-on-hover search-page-card__course-title muted-link"} href={url}>
                      {this.props.card.get('course_name')}
                  </a>);
        } else {
            url = Routes.structure_path(this.props.card.get('structure_slug'));
            return (<a className={this.props.card.get('root_subject') + "-color-on-hover search-page-card__course-title search-page-card__course-title--sleeping muted-link"} href={url}>
                      {this.props.card.get('structure_name')}
                  </a>);
        }
    },

    subjectList: function subjectList () {
        if (this.props.is_popup) { return ''; }
        return (<div className="search-page-card__subjects-wrapper">
                    <SubjectList subjectList={ this.props.card.get('subjects') } />
                </div>);
    },

    goToCourse: function goToCourse (event) {
        if (event.target.nodeName == 'A') { return true; }
        if (this.props.card.get('has_course')) {
            window.location = Routes.structure_indexable_card_path(this.props.card.get('structure_slug'), this.props.card.get('slug'));
        } else {
            window.location = Routes.structure_path(this.props.card.get('structure_slug'));
        }
    },

    // A card do not have to be updated when created.
    shouldComponentUpdate: function shouldComponentUpdate () {
        return false;
    },

    render: function render () {
        var course_information, course_location;
            gift_classes = { gray: this.props.card.get('is_open_for_trial')}
        if (this.props.is_popup) {
            var popup_class = 'search-page__card-popup'
        } else {
            if (this.props.card.get('has_course')) {
                course_information = (<CourseInformation courseType={ this.props.card.get('course_type') || ''} weeklyAvailability={ this.props.card.get('weekly_availability') }
                                      trainings={ this.props.card.get('trainings') } />)
            }
            course_location = (<CourseLocation card={this.props.card} rankingInfo={ this.props.card.get('_rankingInfo') } address={ this.props.card.get('place_address') } />);
        }
        return (
          <div onMouseEnter={this.onMouseEnter}
               onMouseLeave={this.onMouseLeave}
               onClick={this.goToCourse}
               className={"search-page-card soft-half one-quarter palm-one-whole lap-one-third inline-block v-top " + popup_class}>
              <div className="search-page-card__number">{this.props.index}.</div>
              <div className="bg-white search-page-card__content">
                  {this.headerCard()}
                  <div className="soft-half--sides soft-half--bottom">
                      {this.subjectList()}
                      <div className="search-page-card__content-bottom flexbox">
                          <div className="flexbox__item v-bottom">
                              <Rating comment_count={ this.props.card.get('comments_count') } />
                              {course_information}
                              {course_location}
                          </div>
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Card;
