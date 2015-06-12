var CardStore            = require('../stores/CardStore'),
    SearchPageDispatcher = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
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
        var header_message;
        if (this.state.card_store.loading) {
            header_message = (<div>Chargement</div>);
        }
        var cards = this.state.card_store.map(function(card, index) {
            return (
              <Card card={ card } key={ index }/>
            )
        })
        return (
          <div className="bg-white relative z-index-1 main-container" style={{ minHeight: '500px'}}>
            {header_message}
            {cards}
          </div>
        );
    }
});

module.exports = ResultList;
