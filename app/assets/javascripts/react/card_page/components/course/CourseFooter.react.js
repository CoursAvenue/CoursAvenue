var PriceGroup    = require('../PriceGroup.react'),
    CourseStore   = require('../../stores/CourseStore'),
    FluxBoneMixin = require("../../../mixins/FluxBoneMixin");

var CourseFooter = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store'])
    ],

    getInitialState: function getInitialState () {
        return { course_store: CourseStore };
    },

    componentDidMount: function componentDidMount () {
        $(this.getDOMNode).find('[data-behavior=toggleable]').toggler();
    },

    getDescription: function getDescription (course) {
        if (this.props.hide_description) { return; }
        if (course.get('description')) {
            return (<div className="last-p-flush soft--sides hidden" id={"course-description-" + course.get('id')}>
                        <div className="soft--top"
                            dangerouslySetInnerHTML={{__html: COURSAVENUE.helperMethods.simpleFormat(course.get('description')) }}>
                        </div>
                    </div>)
        }
    },
    getPriceGroup: function getPriceGroup (course) {
        if (course.get('price_group_prices') && course.get('price_group_prices').length > 0) {
            return (<div className="hidden" id={"course-price-" + course.get('id')}>
                        <div className="soft--top">
                            <PriceGroup course={course}
                                        prices={course.get('price_group_prices')}/>
                        </div>
                    </div>)
        }
    },
    render: function render () {
        var padding_class, price_button, description_button;
        var course = this.state.course_store.getCourseByID(this.props.course_id);
        if (false) {//course.get('price_group_prices') && course.get('price_group_prices').length > 0) {
            price_button = (<a href="javascript:void(0)"
                               className='btn btn--small btn--white'
                               data-behavior='toggleable'
                               data-el={"#course-price-" + course.get('id')} >
                                Tarifs&nbsp;<i className="fa fa-chevron-down milli"></i>
                            </a>);

        }
        if (course.get('description') && course.get('description').length > 0) {
            description_button = (<a href="javascript:void(0)"
                                       className='btn btn--small btn--white push-half--right'
                                       data-behavior='toggleable'
                                       data-el={"#course-description-" + course.get('id')} >
                                        Description&nbsp;<i className="fa fa-chevron-down milli"></i>
                                    </a>);

        }
        padding_class = (price_button || description_button ? "soft--bottom soft--top" : '');
        return (<div className={"bordered--bottom " + padding_class}>
                    <div className="soft--sides">
                        {description_button}{price_button}
                    </div>
                    { this.getDescription(course) }
                    { this.getPriceGroup(course) }

                </div>);
    }
});

module.exports = CourseFooter;
