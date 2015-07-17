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

    render: function render () {
        var header_message, no_results;
        if (this.state.card_store.loading) {
            header_message = (<div className="spinner">
                                  <div className="double-bounce1"></div>
                                  <div className="double-bounce2"></div>
                                  <div className="double-bounce3"></div>
                              </div>);
        } else {
            var cards = this.state.card_store.where({ visible: true }).map(function(card, index) {
                return (
                  <Card card={ card } index={this.state.card_store.indexOf(card) + 1} key={ card.get('id') }/>
                )
            }.bind(this));
            if (cards.length == 0) {
                no_results = (<Suggestions />);
            }
        }
        return (
          <div className="relative z-index-1 main-container main-container--1000">
              {header_message}
              {cards}
              {no_results}
          </div>
        );
    }
});

module.exports = ResultList;
