var CourseStore   = require('../../stores/CourseStore'),
    FluxBoneMixin = require("../../../mixins/FluxBoneMixin");

var CourseHeader = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store'])
    ],

    getInitialState: function getInitialState () {
        return { course_store: CourseStore };
    },

    getPrice: function getPrice (course) {
        if (this.props.hide_header_details) { return; }
        var price;
        if (!course || !course.get('min_price_amount')) { return; }

        if (course.get('db_type') == 'Course::Training') {
            price = (<strong>{COURSAVENUE.helperMethods.readableAmount(course.get('min_price_amount'), '€')}</strong>);
        } else if (course.get('min_price_amount') == 0) {
            price = (<strong>{"Cours d'essai gratuit"}</strong>);
        } else {
            price = (<strong>{"Cours d'essai à " + COURSAVENUE.helperMethods.readableAmount(course.get('min_price_amount'), '€')}</strong>);
        }
        return (<div className="float--right blue-green nowrap v-middle delta">
                    {price}
                </div>);
    },
    getSubjects: function getSubjects (course) {
        if (this.props.hide_header_details) { return; }
        if (course.get('child_subjects')) {
            subjects = _.map(course.get('child_subjects'), function(subject, index) {
                var city = (course.get('places') && course.get('places')[0].city ? course.get('places')[0].city : 'paris');
                return (<a key={ index } href={Routes.search_page_path(subject.root_slug, subject.slug, city)}
                           className={"search-page-card__subject white bg-" + subject.root_slug}
                           target="_blank">
                            {subject.name}
                        </a>);
            });
            return (<div className="push-half--bottom">{ subjects }</div>);
        }
    },
    render: function render () {
        var subjects, href;
        var course = this.state.course_store.getCourseByID(this.props.course_id);
        if (course) {
            if (course.get('indexable_card_slug')) {
                href = Routes.structure_indexable_card_path(course.get('structure_slug'), course.get('indexable_card_slug'));
            }
            return (<div className="soft--sides soft--top">
                        { this.getPrice(course) }
                        <h3 className="push-half--bottom">
                              <a className="semi-muted-link"
                                      href={href}>
                                      {course.get('name')}
                              </a>
                        </h3>
                        { this.getSubjects(course) }
                    </div>);
        } else {
            return (<div></div>);
        }
    }
});

module.exports = CourseHeader;
