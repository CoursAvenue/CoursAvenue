var ReactPropTypes        = React.PropTypes,
    ResultInfoItem        = require('./ResultInfoItem'),
    CardStore             = require('../stores/CardStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var ResultInfo = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState() {
        return { card_store: CardStore };
    },

    render: function render () {
        var total_results = this.state.card_store.total_results || 0;
        var facets = []
        if (this.state.card_store.facets && this.state.card_store.facets[0]) {
            var index = 0;
            facets = _.map(this.state.card_store.facets[0].data, function(value, key) {
                index += 1;
                return (<ResultInfoItem number={value}
                                        subject_name={key.split(':')[1]}
                                        subject_slug={key.split(':')[0]}
                                        show_dash={(index > 1)}/>);
            });
        }
        var result_string = (total_results > 1 ? 'résultats' : 'résultat');
        return (
          <div className="main-container delta soft--ends soft-half--sides bg-white text-ellipsis">
              <strong>{total_results} {result_string} :</strong> {facets}
          </div>
        );
    }
});

module.exports = ResultInfo;
