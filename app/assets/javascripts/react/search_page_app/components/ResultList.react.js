var CardStore              = require('../stores/CardStore'),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    SubjectActionCreators  = require("../actions/SubjectActionCreators"),
    CardActionCreators     = require("../actions/CardActionCreators"),
    FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    Suggestions            = require("./Suggestions"),
    Card                   = require("./Card");

ResultList = React.createClass({
    mixins: [
        FluxBoneMixin('card_store')
    ],

    // Bootstraping data
    componentWillMount: function componentWillMount() {
        LocationActionCreators.filterByAddress(this.props.address);
        if (this.props.per_page) {
            CardActionCreators.updateNbCardsPerPage(this.props.per_page);
        }
        if (this.props.root_subject) {
            SubjectActionCreators.selectRootSubject(this.props.root_subject);
        }
        if (this.props.subject) {
            SubjectActionCreators.selectSubject(this.props.subject);
        }
    },

    getInitialState: function getInitialState() {
        return { card_store: CardStore, per_line: 4 };
    },

    getCardClass: function getCardClass () {
        switch(this.props.per_line || this.state.per_line) {
            case 1: return 'one-whole';
            case 2: return 'one-half';
            case 3: return 'one-third';
            case 4: return 'one-quarter';
        }
    },

    render: function render () {
        var spinner, no_results;
        if (this.state.card_store.loading) {
            spinner = (<div className="spinner">
                           <div className="double-bounce1"></div>
                           <div className="double-bounce2"></div>
                           <div className="double-bounce3"></div>
                       </div>);
        } else {
            var card_class = this.getCardClass();
            var cards = this.state.card_store.where({ visible: true }).map(function(card, index) {
                return (
                  <Card follow_links={this.props.follow_links} width_class={card_class} card={ card } index={this.state.card_store.indexOf(card) + 1} key={ card.get('id') }/>
                )
            }.bind(this));
            if (cards.length == 0) {
                no_results = (<Suggestions />);
            }
        }
        return (
          <div className="relative z-index-1">
              {spinner}
              {cards}
              {no_results}
          </div>
        );
    }
});

module.exports = ResultList;
