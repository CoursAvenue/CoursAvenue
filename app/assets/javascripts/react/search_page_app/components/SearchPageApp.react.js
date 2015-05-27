var Map                  = require('./Map.react'),
    ResultList           = require('./ResultList.react'),
    ServerActionCreators = require('../actions/ServerActionCreators'),
    PlanningStore        = require('../stores/PlanningStore');

var SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
        plannings: React.PropTypes.array
    },

    getInitialState: function getInitialState() {
        return { planning_store: PlanningStore };
    },

    componentDidMount: function componentDidMount() {
        ServerActionCreators.fetchData({});
    },
    // componentWillUnmount: function componentWillUnmount() { },

    /**
     * @return {object}
     */
    render: function render() {
        return (
          <div>
            <Map
              center={this.props.map_center}
              planning_store={this.state.planning_store}
              />
            <ResultList
              planning_store={this.state.planning_store}
            />
          </div>
        );
    }

});

module.exports = SearchPageApp;
