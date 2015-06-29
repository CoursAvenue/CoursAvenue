var TrainingPlanning = require('../plannings/Training.react');

var Training = React.createClass({

    propTypes: {
        plannings: React.PropTypes.array.isRequired,
    },

    render: function render () {
        var plannings = _.map(this.props.plannings, function(planning) {
            return (<TrainingPlanning planning={planning} />);
        });
        return (
            <table className="table--striped table--data table--data-small table-responsive">
                <thead className="gray-light">
                    <tr>
                        <th className="one-tenths">Jour</th>
                        <th className="two-tenths">Horaires</th>
                        <th className="two-tenths">Niveau</th>
                        <th className="two-tenths">Public</th>
                        <th><i className="fa-info"></i></th>
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
