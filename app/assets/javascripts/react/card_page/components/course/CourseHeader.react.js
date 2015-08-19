var CourseStore   = require('../../stores/CourseStore'),
    SubjectList   = require('../../../search_page_app/components/cards/SubjectList'),
    FluxBoneMixin = require("../../../mixins/FluxBoneMixin");

var CourseHeader = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store'])
    ],

    getInitialState: function getInitialState () {
        return { course_store: CourseStore };
    },

    getPrice: function getPrice (course) {
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
    render: function render () {
        var subjects;
        var course = this.state.course_store.getCourseByID(this.props.course_id);
        if (course) {
            if (course.get('child_subjects')) {
                subjects = _.map(course.get('child_subjects'), function(subject) {
                    var city = (course.get('places') && course.get('places')[0].city ? course.get('places')[0].city : 'paris');
                    return (<a href={Routes.search_page_path(subject.root_slug, subject.slug, city)}
                               className={"search-page-card__subject bg-" + subject.root_slug +"-on-hover"}
                               target="_blank">
                                {subject.name}
                            </a>);
                });
            }

            return (<div className="soft--sides">
                        { this.getPrice(course) }
                        <h3 className="push-half--bottom">{course.get('name')}</h3>
                        <div className="push-half--bottom">{ subjects }</div>
                    </div>);
        } else {
            return (<div></div>);
        }
    }
});

module.exports = CourseHeader;
