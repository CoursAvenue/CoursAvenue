var _                    = require('lodash'),
    Course               = require('../../card_page/components/course.react'),
    CourseActionCreators = require('../../card_page/actions/CourseActionCreators');

var EmailPlanning = React.createClass({

    getInitialState: function getInitialState() {
        return {};
    },

    componentDidMount: function componentDidMount () {
        var course_string = '';
        _.each(this.props.courses, function(course) {
            CourseActionCreators.bootstrapCourse(course);
            course_string += React.renderToString(<Course show_header={true}
                                                  hide_header_details={true}
                                                          show_footer={false}
                                                        dont_register={false}
                                                        show_location={true}
                                                         structure_id={this.props.structure_id}
                                                            course_id={course.id} />);

        }, this);
        $('[data-type="redactor"]').redactor('insert.set', course_string    );
    },

    render: function render () {
        return (<div></div>);
    }
});

module.exports = EmailPlanning;
