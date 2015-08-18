var Planning = require('../Planning.react');

var Training = React.createClass({

    propTypes: {
        plannings: React.PropTypes.array.isRequired,
    },

    render: function render () {
        var location_th;
        var plannings = _.map(this.props.plannings, function(planning, index) {
            return (<Planning planning={planning}
                              dont_register={this.props.dont_register}
                              show_location={this.props.show_location}
                              course={this.props.course}
                              key={index} />);
        }.bind(this))
        if (this.props.show_location) {
            location_th = (<th className="two-tenths">Lieu</th>);
        }
        return (
            <table className={"table--striped table--data table-responsive table-responsive--without-th " + (this.props.course.structure_is_active ? 'table--hoverable' : '')}>
                <thead className="gray-light">
                    <tr>
                        <th className="soft--left three-tenths">Jour & heure</th>
                        <th className="two-tenths">Niveau</th>
                        <th className="two-tenths">Public</th>
                        { location_th }
                        <th className={ this.props.course.structure_is_active ? '' : 'hidden'}></th>
                    </tr>
                </thead>
                <tbody>
                    {plannings}
                </tbody>
            </table>
        );
    }
});

module.exports = Training;
