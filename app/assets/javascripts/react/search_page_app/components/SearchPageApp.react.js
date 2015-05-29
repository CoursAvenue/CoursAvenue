var Map                  = require('./Map.react'),
    ResultList           = require('./ResultList.react'),
    SubjectFilter        = require('./SubjectFilter.react'),
    FilterBar            = require('./FilterBar.react'),
    PlanningStore        = require('../stores/PlanningStore');

var SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
    },

    render: function render() {
        return (
          <div className="relative">
            <Map center={this.props.map_center} />
            <SubjectFilter />
            <FilterBar />
            <ResultList />
          </div>
        );
    }

});

module.exports = SearchPageApp;
