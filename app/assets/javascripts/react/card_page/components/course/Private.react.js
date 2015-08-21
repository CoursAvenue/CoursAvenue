var Planning      = require('../Planning.react'),
    CourseStore   = require('../../stores/CourseStore'),
    FluxBoneMixin = require("../../../mixins/FluxBoneMixin");

var Private = React.createClass({

    mixins: [
        FluxBoneMixin(['course_store'])
    ],

    getInitialState: function getInitialState () {
        return { course_store: CourseStore };
    },

    render: function render () {
        var location_th, plannings;
        var course = this.state.course_store.getCourseByID(this.props.course_id);
        if (course) {
            plannings = _.map(course.get('plannings'), function(planning, index) {
                return (<Planning planning={planning}
                                  dont_register={this.props.dont_register}
                                  show_location={this.props.show_location}
                                  course={course}
                                  key={index} />);
            }.bind(this));
        }
        if (this.props.show_location) {
            location_th = (<th className="two-tenths">Lieu</th>);
        }
        return (
            <table className={"flush table--striped table--data table-responsive table-responsive--without-th " + (course.get('structure_is_active') ? 'table--hoverable' : '')}>
                <thead className="gray-light">
                    <tr>
                        <th className={"soft--left " + (this.props.show_location ? 'three-tenths' : '')}>
                            Jour & heure
                        </th>
                        <th className={(this.props.show_location ? 'two-tenths' : '')}>Niveau</th>
                        <th className={(this.props.show_location ? 'two-tenths' : '')}>Public</th>
                        { location_th }
                        <th style={{ width: '8em' }}
                            className={ course.get('structure_is_active') ? '' : 'hidden'}></th>
                    </tr>
                </thead>
                <tbody>
                    {plannings}
                </tbody>
            </table>
        );
    }
});

module.exports = Private;
