var Map                  = require('./Map.react'),
    ResultList           = require('./ResultList.react'),
    SubjectList          = require('./SubjectList.react'),
    PlanningStore        = require('../stores/PlanningStore');

var SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
    },

    render: function render() {
        return (
          <div>
            <Map center={this.props.map_center} />
            <SubjectList />
            <ResultList />
          </div>
        );
    }

});

module.exports = SearchPageApp;
