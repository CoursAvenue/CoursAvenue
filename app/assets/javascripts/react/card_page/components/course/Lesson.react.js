var Planning = require('../Planning.react');

var Lesson = React.createClass({

    propTypes: {
        plannings: React.PropTypes.array.isRequired,
        course: React.PropTypes.array.isRequired,
    },

    render: function render () {
        var location_th;
        var plannings = _.map(this.props.plannings, function(planning, index) {
            return (<Planning planning={planning}
                              dont_register={this.props.dont_register}
                              show_location={this.props.show_location}
                              course={this.props.course}
                              key={index} />);
        }.bind(this));
        if (this.props.show_location) {
            location_th = (<th className="two-tenths">Lieu</th>);
        }
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
                        <i className='delta fa fa-repeat v-middle'></i>
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
                            <i className='delta fa fa-calendar v-middle'></i>
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
                <div className="soft--sides">
                    {infos}
                </div>
                <table className={"table--striped table--data table-responsive table-responsive--without-th " + (this.props.course.structure_is_active ? 'table--hoverable' : '')}>
                    <thead className="gray-light">
                        <tr>
                            <th className={"soft--left " + (this.props.show_location ? 'three-tenths' : '')}>
                                Jour & heure
                            </th>
                            <th className="three-tenths">Niveau</th>
                            <th className="two-tenths">Public</th>
                            { location_th }
                            <th style={{ width: '8em' }}
                                className={ this.props.course.structure_is_active ? '' : 'hidden'}></th>
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
