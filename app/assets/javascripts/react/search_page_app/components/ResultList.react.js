var PlanningStore        = require('../stores/PlanningStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FullPageLoading      = require('./FullPageLoading.react'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin");

var ResultList = React.createClass({
    mixins: [
        FluxBoneMixin('planning_store')
    ],

    render: function render () {
        var header_message;
        if (this.props.planning_store.loading) {
            header_message = (<FullPageLoading text="Loading..."></FullPageLoading>);
        }
        var planning_views = this.props.planning_store.map(function(planning) {
            return (
              <div className="soft push-half--right inline-block bg-white bordered" style={{width: '300px'}}>
                  <h4>{planning.get('course_name')}</h4>
                  <div className="gray">{planning.get('structure_name')}</div>
              </div>
            )
        })
        // {this.props.planning_store}
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
