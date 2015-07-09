var ReactPropTypes        = React.PropTypes,
    ResultInfoItem        = require('./ResultInfoItem'),
    CardStore             = require('../stores/CardStore'),
    FilterActionCreators  = require("../actions/FilterActionCreators");
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var ResultInfo = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState() {
        return { card_store: CardStore };
    },

    updateResultSorting: function updateResultSorting(event) {
        FilterActionCreators.updateSorting(event.currentTarget.value);
    },

    render: function render () {
        return (
          <select onChange={this.updateResultSorting}>
              <option value="distance">Les + proches</option>
              <option value="comment_count">{"Le + d'avis"}</option>
          </select>
        );
    }
});

module.exports = ResultInfo;
