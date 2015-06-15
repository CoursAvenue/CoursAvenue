var FilterStore           = require('../stores/FilterStore'),
    RootSubjectItem       = require('./RootSubjectItem.react'),
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

    toggleLocationFilter: function toggleLocationFilter () {
        FilterActionCreators.toggleLocationFilter();
    },

    toggleTimeFilter: function toggleTimeFilter () {
        FilterActionCreators.toggleTimeFilter();
    },

    render: function render () {
        var subject = this.state.filter_store.get('subject');
        var subject_name = (subject ? subject.name : '');
        return (
          <div className="text--center bordered--top bordered--bottom bg-white">
              <div className="main-container grid">
                  <div className="grid__item one-third bordered soft-half cursor-pointer" onClick={this.toggleSubjectFilter}>
                    Quoi ?
                  </div>
                  <div className="grid__item one-third bordered soft-half cursor-pointer" onClick={this.toggleLocationFilter}>
                    Où ?
                  </div>
                  <div className="grid__item one-third bordered soft-half cursor-pointer" onClick={this.toggleTimeFilter}>
                    Quand ?
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
