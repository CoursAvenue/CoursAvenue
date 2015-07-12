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
        var dot_dot_dot = '';
        var total_results = this.state.card_store.total_results || 0;
        var facets = []
        if (this.state.card_store.facets && this.state.card_store.facets[0]) {
            var index = 0;
            // Sort facets by number and only take first 3
            var array_facets = _.map(this.state.card_store.facets[0].data, function(value, key) { return [key, value] });
            array_facets     = _.take(_.sortBy(array_facets, function(array) { return array[1]; }).reverse(), 3);
            facets = _.map(array_facets, function(array) {
                var key = array[0], value = array[1];
                index += 1;
                return (<ResultInfoItem number={value}
                                        subject_name={key.split(':')[1]}
                                        subject_slug={key.split(':')[0]}
                                        key={key} />);
            });
            if (_.size(this.state.card_store.facets[0].data) > 3) {
                dot_dot_dot = (<span className="search-page__result-info search-page__result-info--dot-dot-dot">...</span>);
            }
        }
        var result_string = (total_results > 1 ? 'cours trouvé' : 'cours trouvés');
        return (
          <div className="main-container main-container--1000 soft--ends soft-half--sides text-ellipsis">
              <span className="beta v-middle push--right">{total_results} {result_string}</span>
              &nbsp;{facets}{dot_dot_dot}
          </div>
        );
    }
});

module.exports = ResultInfo;
