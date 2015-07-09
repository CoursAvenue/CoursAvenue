var Planning = require('../Planning.react');

var Private = React.createClass({

    propTypes: {
        plannings: React.PropTypes.array.isRequired,
    },

    render: function render () {
        var plannings = _.map(this.props.plannings, function(planning, index) {
            return (<Planning planning={planning} course={this.props.course} key={index} />);
        }.bind(this))
        return (
            <table className="table--striped table--data table--data-small table-responsive table-responsive--without-th table--hoverable">
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

module.exports = Private;
