var Lesson                 = require('./course/Lesson.react'),
    Private                = require('./course/Private.react'),
    Training               = require('./course/Training.react'),
    CourseStore            = require('../stores/CourseStore'),
    CourseActionCreators   = require('../actions/CourseActionCreators'),
    PlanningActionCreators = require('../actions/PlanningActionCreators'),
    FluxBoneMixin          = require("../../mixins/FluxBoneMixin");

var Course = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store'])
    ],

    getInitialState: function getInitialState () {
        return { course_store: CourseStore };
    },

    componentDidMount: function componentDidMount () {
        this.bootsrapData();
    },

    // Bootstraping data
    bootsrapData: function bootsrapData() {
        if (this.props.course_id) {
            CourseActionCreators.populateCourse(this.props.structure_id, this.props.course_id);
        } else if (this.props.indexable_card_id) {
            CourseActionCreators.populateIndexableCard(this.props.structure_id, this.props.indexable_card_id);
        }
    },

    render: function render () {
        var course = (<div></div>);
        var course_model = this.state.course_store.getCourseByID(this.props.course_id || this.props.indexable_card_id)
        if (course_model) {
            switch(course_model.get('db_type')) {
                case 'Course::Lesson':
                    course = (<Lesson show_location={this.props.show_location}
                                      dont_register={this.props.dont_register}
                                      course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
                case 'Course::Training':
                    course = (<Training show_location={this.props.show_location}
                                      dont_register={this.props.dont_register}
                                      course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
                case 'Course::Private':
                    course = (<Private show_location={this.props.show_location}
                                      dont_register={this.props.dont_register}
                                      course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
            }
        }
        if (this.props.show_course_info) {}
        return course;
    }
});

module.exports = Course;
