var PlanningStore        = require('../stores/PlanningStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin");

var ResultList = React.createClass({
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
        var planning_views = this.state.planning_store.map(function(planning) {
            return (
              <div className="soft push-half--right inline-block bg-white bordered" style={{width: '300px'}}>
                  <h4>{planning.get('course_name')}</h4>
                  <div className="gray">{planning.get('structure_name')}</div>
              </div>
            )
        })
        // {this.state.planning_store}
        return (
          <div style={{ minHeight: '500px'}}>
            <h1>Resultats</h1>
            {header_message}
            {planning_views}
          </div>
        );
    }
});

module.exports = ResultList;
