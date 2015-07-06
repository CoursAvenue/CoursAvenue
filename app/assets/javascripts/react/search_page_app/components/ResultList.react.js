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
            header_message = (<div className="f-weight-bold on-top opacity-75 height-100-percent flex-center alpha absolute one-whole north west">
                                  Chargement...
                              </div>);
        }
        var cards = this.state.card_store.where({ visible: true }).map(function(card, index) {
            return (
              <Card card={ card } index={this.state.card_store.indexOf(card) + 1} key={ index }/>
            )
        }.bind(this));
        if (cards.length == 0) {
            no_results = (<Suggestions />);
        }
        return (
          <div className="relative z-index-1 main-container main-container--1000" style={{ minHeight: '500px'}}>
            {header_message}
            {cards}
            {no_results}
          </div>
        );
    }
});

module.exports = ResultList;
