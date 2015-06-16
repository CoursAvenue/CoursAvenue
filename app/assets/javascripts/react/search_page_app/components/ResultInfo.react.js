var ReactPropTypes        = React.PropTypes,
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    CardStore             = require('../stores/CardStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var RootSubjectItem = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState() {
        return { card_store: CardStore };
    },

    render: function render () {
        var total_results = this.state.card_store.total_results || 0;
        var facets = [];
        if (this.state.card_store.facets && this.state.card_store.facets[0]) {
            facets = _.map(this.state.card_store.facets[0].data, function(value, key) {
                return key + '(' + value + ')';
            });
        }
        return (
          <div className="main-container epsilon soft--ends soft-half--sides bg-white">
              {total_results} Résultats : {facets.join(' - ')}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
