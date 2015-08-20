var SubjectList        = require('./cards/SubjectList.react'),
    CourseInformation  = require('./cards/CourseInformation.react'),
    CourseLocation     = require('./cards/CourseLocation.react'),
    CardActionCreators = require("../actions/CardActionCreators"),
    Card               = require('./Card'),
    Rating             = require('./cards/Rating.react');

CourseCard = React.createClass({

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

    toggleFavorite: function toggleFavorite (event) {
	CardActionCreators.toggleFavorite({ card: this.props.card });
	return false;
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
	    var favorite_class = 'fa ' + ( this.props.card.get('favorite') ?  'fa-heart' : 'fa-heart-o');
            return (<div>
                        <div className="search-page-card__content-top">
                            <div className="relative">
                                {price}
                                {this.headerImage()}
				<div className='search-page-card__favorite north east absolute'>
				    <div onClick={ this.toggleFavorite } className='white delta cursor-pointer'>
					<i className={ favorite_class }></i>
				    </div>
				</div>
                            </div>
                            {this.headerLogo()}
                            <div className="search-page-card__structure-name soft-half--sides gray">
                                <a href={Routes.structure_path(this.props.card.get('structure_slug'))}
                                   target="_blank"
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
            return (<a className={this.props.card.get('root_subject') + "-color-on-hover search-page-card__course-title muted-link"}
                       target="_blank"
                       href={url}>
                      {this.props.card.get('course_name')}
                  </a>);
        } else {
            url = Routes.structure_path(this.props.card.get('structure_slug'));
            return (<a className={this.props.card.get('root_subject') + "-color-on-hover search-page-card__course-title search-page-card__course-title--sleeping muted-link"}
                       target="_blank"
                       href={url}>
                      {this.props.card.get('structure_name')}
                  </a>);
        }
    },

    subjectList: function subjectList () {
        if (this.props.is_popup) { return ''; }
        if (this.props.card.get('subjects').length > 0) {
            return (<SubjectList follow_links={this.props.follow_links}
                                 subject_list={ this.props.card.get('subjects') } />);
        } else {
            return (<div className="search-page-card__subjects-wrapper"></div>);
        }
    },

    goToCourse: function goToCourse (event) {
        var new_location;
        if (event.target.nodeName == 'A') { return true; }
        if (this.props.card.get('has_course')) {
            new_location = Routes.structure_indexable_card_path(this.props.card.get('structure_slug'), this.props.card.get('slug'));
        } else {
            new_location = Routes.structure_path(this.props.card.get('structure_slug'));
        }
        window.open(new_location);
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
            var popup_class = ''
            if (this.props.card.get('has_course')) {
                course_information = (<CourseInformation courseType={ this.props.card.get('course_type') || ''} weeklyAvailability={ this.props.card.get('weekly_availability') }
                                      trainings={ this.props.card.get('trainings') } />)
            }
            course_location = (<CourseLocation follow_links={this.props.follow_links} card={this.props.card} rankingInfo={ this.props.card.get('_rankingInfo') } address={ this.props.card.get('place_address') } />);
        }
        var options = {
            onMouseEnter: this.onMouseEnter,
            onMouseLeave: this.onMouseLeave,
            onClick:      this.goToCourse,
            classes:      this.props.width_class + ' ' + popup_class,
            index:        this.props.index
        }

        return (
            <Card {...options}>
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
            </Card>
        );
    }
});

module.exports = CourseCard;
