var Planning      = require('../Planning.react'),
    CourseStore   = require('../../stores/CourseStore'),
    FluxBoneMixin = require("../../../mixins/FluxBoneMixin");

var Lesson = React.createClass({

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
        var infos = [];
        if (course.get('teaches_at_home')) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-house v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;Se déplace à domicile
                            </div>
                        </div>));
        }
        if (course.get('on_appointment')) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-phone v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;Pas de créneau précis, uniquement sur demande
                            </div>
                        </div>));
        }
        infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                        <i className='delta fa fa-repeat v-middle'></i>
                        <div className='inline-block v-middle'>
                            &nbsp;{course.get('frequency')}
                        </div>
                    </div>));
        if (course.get('cant_be_joined_during_year')) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-forbidden v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Pas d'inscription en cours d'année"}
                            </div>
                        </div>));
        } else {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-calendar v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Inscriptions tout au long de l'année"}
                            </div>
                        </div>));
        }
        if (course.get('no_class_during_holidays')) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-forbidden v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Pas de cours pendant les vacances scolaires"}
                            </div>
                        </div>));
        }

        return (
            <div>
                <div className="soft--sides">
                    {infos}
                </div>
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
            </div>
        );
    }
});

module.exports = Lesson;
