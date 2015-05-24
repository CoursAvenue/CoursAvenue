var Map                      = require('./Map.react'),
    ResultSearch             = require('./ResultSearch.react'),
    PlanningsCollectionStore = require('../stores/PlanningsCollectionStore');

var SearchPageApp = React.createClass({
    propTypes: {
        map_center: React.PropTypes.array,
        plannings: React.PropTypes.array
    },


    getInitialState: function getInitialState() {
        return {};
    },

    componentDidMount: function componentDidMount() {
      // TodoStore.addChangeListener(this._onChange);
        debugger
    },

    componentWillUnmount: function componentWillUnmount() {
      // TodoStore.removeChangeListener(this._onChange);
        debugger
    },

    /**
     * @return {object}
     */
    render: function render() {
        return (
          <div>
            <Map
              center={this.props.map_center} />
            <ResultSearch
              collection={this.props.plannings}
            />
          </div>
        );
    }

});

module.exports = SearchPageApp;
