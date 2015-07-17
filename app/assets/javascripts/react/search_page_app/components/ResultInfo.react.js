var _                     = require('lodash'),
    ReactPropTypes        = React.PropTypes,
    ResultInfoItem        = require('./ResultInfoItem'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    CardListSortBy        = require('./CardListSortBy'),
    CardStore             = require('../stores/CardStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var ResultInfo = React.createClass({

    mixins: [
        FluxBoneMixin('card_store')
    ],

    getInitialState: function getInitialState() {
        return { card_store: CardStore };
    },

    showSubjectFilterPanel: function showSubjectFilterPanel () {
        FilterActionCreators.toggleSubjectFilter();
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
                var popover_facet_content = _.map(this.state.card_store.facets[0].data, function(value, key) {
                    return key.split(':')[1] + '&nbsp;(' + value + ')';
                });
                dot_dot_dot = (<span className="cursor-pointer search-page__result-info search-page__result-info--dot-dot-dot"
                                      onClick={this.showSubjectFilterPanel}
                                      data-toggle="popover"
                                      data-content={_.trunc(popover_facet_content.splice(3).join(', '), 200)}
                                      data-trigger="hover"
                                      data-html="true"
                                      data-placement="top"
                                      data-original-title="">
                                   <i className="fa fa-circle"></i>
                                   <i className="fa fa-circle"></i>
                                   <i className="fa fa-circle"></i>
                               </span>);
            }
        }
        var result_string = (total_results > 1 ? 'cours trouvé' : 'cours trouvés');
        return (
          <div className="main-container main-container--1000 soft--ends flexbox">
              <div className="flexbox__item v-middle nowrap palm-one-whole">
                  <span className="beta v-middle push--right">{total_results} {result_string}</span>
              </div>
              <div className="flexbox__item v-middle palm-one-whole one-whole">
                  {facets}{dot_dot_dot}
              </div>
              <div className="flexbox__item v-middle nowrap palm-one-whole text--right">
                  <CardListSortBy />
              </div>
          </div>
        );
    }
});

module.exports = ResultInfo;
