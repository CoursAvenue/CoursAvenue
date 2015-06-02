var PlanningStore        = require('../stores/PlanningStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    Card                 = require("./Card");

ResultList = React.createClass({
    mixins: [
        FluxBoneMixin('planning_store')
    ],

    getInitialState: function getInitialState() {
        return { planning_store: PlanningStore };
    },

    componentDidMount: function componentDidMount() {},

    render: function render () {
        var header_message;
        if (this.state.planning_store.loading) {
            header_message = (<div>Chargement</div>);
        }
        var cards = this.state.planning_store.map(function(planning) {
            return (
              <Card planning={planning}/>
            )
        })
        // {this.state.planning_store}
        return (
          <div className="main-container" style={{ minHeight: '500px'}}>
            <h1>Resultats</h1>
            {header_message}
            {cards}
          </div>
        );
    }
});

module.exports = ResultList;
