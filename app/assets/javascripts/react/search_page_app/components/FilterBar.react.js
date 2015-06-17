var RootSubjectItem       = require('./RootSubjectItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var FilterBar = React.createClass({

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
