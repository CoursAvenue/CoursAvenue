var CardStore              = require('../stores/CardStore'),
    HelpStore              = require('../stores/HelpStore'),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    SubjectActionCreators  = require("../actions/SubjectActionCreators"),
    CardActionCreators     = require("../actions/CardActionCreators"),
    FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    Suggestions            = require("./Suggestions"),
    HelpCard               = require("./HelpCard"),
    EmptyCard              = require("./EmptyCard"),
    CourseCard             = require("./CourseCard");

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
        var fake_cards, no_results;
        this.helper_card_position = this.helper_card_position || (Math.ceil(Math.random() * 5) + 2);
        if (this.state.card_store.first_loading) {
            fake_cards = [(<EmptyCard />), (<EmptyCard />), (<EmptyCard />),
                          (<EmptyCard />), (<EmptyCard />), (<EmptyCard />),
                          (<EmptyCard />), (<EmptyCard />), (<EmptyCard />)];
        } else {
            var card_class = this.getCardClass();
            var helper_cards = HelpStore.getUnseenCards();
            var cards = this.state.card_store.where({ visible: true }).map(function(card, index) {
                return (
                  <CourseCard follow_links={this.props.follow_links} width_class={card_class} card={ card } index={this.state.card_store.indexOf(card) + 1} key={ card.get('id') }/>
                )
            }.bind(this));
            if (cards.length == 0) {
                no_results = (<Suggestions />);
            }

            if (helper_cards.length > 0) {
                var helper_card = (
                    <HelpCard helper={ helper_cards[0] } key={ helper_cards[0].get('type') } width_class={ card_class } />
                )

                cards.splice(this.helper_card_position, 0, helper_card);
                cards.splice(-1, 1);
            }
        }
        return (
          <div className="relative z-index-1">
              {fake_cards}
              {cards}
              {no_results}
          </div>
        );
    }
});

module.exports = ResultList;
