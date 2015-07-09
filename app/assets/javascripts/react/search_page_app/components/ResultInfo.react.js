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
                                        key={key} />);
            });
        }
        var result_string = (total_results > 1 ? 'cours trouvé' : 'cours trouvés');
        return (
          <div className="main-container main-container--1000 soft--ends soft-half--sides text-ellipsis">
              <span className="beta v-middle push--right">{total_results} {result_string}</span>&nbsp;{facets}
          </div>
        );
    }
});

module.exports = ResultInfo;
