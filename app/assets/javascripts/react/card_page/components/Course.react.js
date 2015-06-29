var Lesson                 = require('./course/Lesson.react'),
    Private                = require('./course/Private.react'),
    Training               = require('./course/Training.react'),
    BookPopup              = require('./BookPopup.react'),
    CourseActionCreators   = require('../actions/CourseActionCreators'),
    PlanningActionCreators = require('../actions/PlanningActionCreators');

var Course = React.createClass({

    propTypes: {
        course: React.PropTypes.object.isRequired,
    },

    componentDidMount: function componentDidMount () {
        this.bootsrapData();
    },

    // Bootstraping data
    bootsrapData: function bootsrapData() {
        CourseActionCreators.populateCourse(this.props.course);
        PlanningActionCreators.populatePlannings(this.props.plannings);
    },

    render: function render () {
        var course;
        switch(this.props.course.db_type) {
            case 'Course::Lesson':
                course = (<Lesson course={this.props.course} plannings={this.props.plannings} />);
                break;
            case 'Course::Training':
                course = (<Training course={this.props.course} plannings={this.props.plannings} />);
                break;
            case 'Course::Private':
                course = (<Private course={this.props.course} plannings={this.props.plannings} />);
                break;
        }
        this.props.course
        return course;
    }
});

module.exports = Course;
