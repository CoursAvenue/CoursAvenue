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
        var facets = [];
        if (this.state.card_store.facets) {
            facets = _.map(this.state.card_store.facets[0].data, function(value, key) {
                return key + '(' + value + ')';
            });
        }
        return (
          <div className="inline-block bordered push-half--right very-soft bg-gray-light">
              {this.state.card_store.count} Résultats : {facets.join(', ')}
          </div>
        );
    }
});

module.exports = RootSubjectItem;
