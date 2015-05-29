var FilterStore           = require('../stores/FilterStore'),
    RootSubjectItem       = require('../components/RootSubjectItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var FilterBar = React.createClass({
    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return { filter_store: FilterStore };
    },

    toggleSubjectFilter: function toggleSubjectFilter () {
        FilterActionCreators.toggleSubjectFilter();
    },

    render: function render () {
        return (
          <div className="text--center bordered--top bordered--bottom">
              <div className="main-container grid">
                  <div className="grid__item one-third bordered soft-half cursor-pointer">
                    Où ?
                    {this.state.filter_store.get('location_filter')}
                  </div>
                  <div className="grid__item one-third bordered soft-half cursor-pointer" onClick={this.toggleSubjectFilter}>
                    Quoi ?
                    {this.state.filter_store.get('subject')}
                  </div>
                  <div className="grid__item one-third bordered soft-half cursor-pointer">
                    Quand ?
                    {this.state.filter_store.get('time')}
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
