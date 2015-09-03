var Lesson                 = require('./course/Lesson.react'),
    Private                = require('./course/Private.react'),
    Training               = require('./course/Training.react'),
    CourseHeader           = require('./course/CourseHeader.react'),
    CourseFooter           = require('./course/CourseFooter.react'),
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
        if (this.props.indexable_card_id) {
            CourseActionCreators.populateIndexableCard(this.props.structure_id, this.props.indexable_card_id);
        } else {
            CourseActionCreators.populateCourses(this.props.structure_id);
        }
    },

    render: function render () {
        var course_header, course_planning, course_footer, spinner;
        var course_model = this.state.course_store.getCourseByID(this.props.course_id || this.props.indexable_card_id)
        if (course_model && course_model.get('plannings')) {
            switch(course_model.get('db_type')) {
                case 'Course::Lesson':
                    course_planning = (<Lesson show_location={this.props.show_location}
                                         hide_header_details={this.props.hide_header_details}
                                               dont_register={this.props.dont_register}
                                          show_planning_link={this.props.show_planning_link}
                                                   course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
                case 'Course::Training':
                    course_planning = (<Training show_location={this.props.show_location}
                                           hide_header_details={this.props.hide_header_details}
                                                 dont_register={this.props.dont_register}
                                            show_planning_link={this.props.show_planning_link}
                                                     course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
                case 'Course::Private':
                    course_planning = (<Private show_location={this.props.show_location}
                                          hide_header_details={this.props.hide_header_details}
                                                dont_register={this.props.dont_register}
                                           show_planning_link={this.props.show_planning_link}
                                                    course_id={this.props.course_id || this.props.indexable_card_id} />);
                    break;
            }
            if (this.props.show_header) {
                this.props.hide_header_details = (_.isBoolean(this.props.hide_header_details) ? this.props.hide_header_details : false);
                course_header = (<CourseHeader key={this.props.course_id + 'header'}
                                     dont_register={this.props.dont_register}
                               hide_header_details={this.props.hide_header_details}
                                         course_id={this.props.course_id || this.props.indexable_card_id} />);
            }
            if (this.props.show_footer) {
                course_footer = (<CourseFooter key={this.props.course_id + 'footer'}
                                  hide_description={this.props.hide_description}
                                         course_id={this.props.course_id || this.props.indexable_card_id} />);
            }
        } else {
            spinner = (<div className="spinner">
                           <div className="double-bounce1"></div>
                           <div className="double-bounce2"></div>
                           <div className="double-bounce3"></div>
                       </div>);
        }
        return  (<div>
                    { spinner }
                    { course_header }
                    { course_planning }
                    { course_footer }
                 </div>);
    }
});

module.exports = Course;
