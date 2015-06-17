var CardStore            = require('../stores/CardStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    Suggestions          = require("./Suggestions"),
    Card                 = require("./Card");

ResultList = React.createClass({
    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState() {
        return { card_store: CardStore };
    },

    componentDidMount: function componentDidMount() {},

    render: function render () {
        var header_message, no_results;
        if (this.state.card_store.loading) {
            header_message = (<div className="text--center delta absolute one-whole north west">
                                  Chargement...
                              </div>);
        }
        var cards = this.state.card_store.map(function(card, index) {
            return (
              <Card card={ card } key={ index }/>
            )
        })
        if (cards.length == 0) {
            no_results = (<Suggestions />);
        }
        return (
          <div className="bg-white relative z-index-1 main-container" style={{ minHeight: '500px'}}>
            {header_message}
            {cards}
            {no_results}
          </div>
        );
    }
});

module.exports = ResultList;
