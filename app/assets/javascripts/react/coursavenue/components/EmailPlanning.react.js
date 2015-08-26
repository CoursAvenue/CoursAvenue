var _                    = require('lodash'),
    Course               = require('../../card_page/components/Course.react'),
    CourseActionCreators = require('../../card_page/actions/CourseActionCreators');

var EmailPlanning = React.createClass({

    getInitialState: function getInitialState() {
        return {};
    },

    componentDidMount: function componentDidMount () {
        var course_string = '';
        _.each(this.props.courses, function(course, index) {
            CourseActionCreators.bootstrapCourse(course);
            if (index > 0) {
                course_string += '<div style="padding-top: 10px; padding-bottom: 10px;"><hr style="margin: 0;" /></div>'
            }
            course_string += React.renderToString(<Course show_header={true}
                                                   show_planning_link={true}
                                                  hide_header_details={true}
                                                          show_footer={false}
                                                        dont_register={false}
                                                        show_location={true}
                                                         structure_id={this.props.structure_id}
                                                            course_id={course.id} />);
        }, this);
        setTimeout(function() {
            $('[data-type="redactor"]').redactor('insert.set', '<div></div>');
            $('[data-type="redactor"]').redactor('insert.htmlWithoutClean', course_string);
            setTimeout(function() {
                $('[data-type="redactor"]').trigger('update:content');
            }, 1000);
        }, 1000);
    },

    render: function render () {
        return (<div></div>);
    }
});

module.exports = EmailPlanning;
