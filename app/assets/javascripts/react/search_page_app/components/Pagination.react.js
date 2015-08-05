var CardStore             = require('../stores/CardStore'),
    CardActionCreators    = require("../actions/CardActionCreators"),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin"),
    Pagination            = require("../../mixins/Pagination");

var CardPagination = React.createClass({

    mixins: [
        FluxBoneMixin('card_store'),
        Pagination('card_store', CardActionCreators)
    ],

    getInitialState: function getInitialState() {
        return {
            card_store: CardStore,
            large: true
        };
    }
});

module.exports = CardPagination;
