var LessonPlanning = require('../plannings/Lesson.react');

var Lesson = React.createClass({

    propTypes: {
        plannings: React.PropTypes.array.isRequired,
        course: React.PropTypes.array.isRequired,
    },

    render: function render () {
        var plannings = _.map(this.props.plannings, function(planning, index) {
            return (<LessonPlanning planning={planning} course={this.props.course} key={index} />);
        }.bind(this));

        var infos = [];
        if (this.props.course.teaches_at_home) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-house v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;Se déplace à domicile
                            </div>
                        </div>));
        }
        if (this.props.course.on_appointment) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-phone v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;Pas de créneau précis, uniquement sur demande
                            </div>
                        </div>));
        }
        infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                        <i className='delta fa fa-calendar v-middle'></i>
                        <div className='inline-block v-middle'>
                            &nbsp;{this.props.course.frequency}
                        </div>
                    </div>));
        if (this.props.course.cant_be_joined_during_year) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-forbidden v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Pas d'inscription en cours d'année"}
                            </div>
                        </div>));
        } else {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-forbidden v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Inscriptions tout au long de l'année"}
                            </div>
                        </div>));
        }
        if (this.props.course.no_class_during_holidays) {
            infos.push((<div className='push-half--right push-half--bottom inline-block v-middle'>
                            <i className='delta fa fa-forbidden v-middle'></i>
                            <div className='inline-block v-middle'>
                                &nbsp;{"Pas de cours pendant les vacances scolaires"}
                            </div>
                        </div>));
        }

        return (
            <div>
                {infos}
                <table className="table--striped table--data table--data-small table-responsive table--hoverable">
                    <thead className="gray-light">
                        <tr>
                            <th className="one-tenths">Jour</th>
                            <th className="two-tenths">Horaires</th>
                            <th className="three-tenths">Niveau</th>
                            <th className="two-tenths">Public</th>
                            <th><i className="fa-info"></i></th>
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
