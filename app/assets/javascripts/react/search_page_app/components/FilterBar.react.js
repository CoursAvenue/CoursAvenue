var RootSubjectItem       = require('./RootSubjectItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin"),
    cx                    = require('classnames/dedupe'),
    FilterPanelConstants  = require('../constants/FilterPanelConstants');

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

    toggleMoreFilter: function toggleMoreFilter () {
        FilterActionCreators.toggleMoreFilter();
    },

    render: function render () {
        return (
          <div className="text--center bordered--top bordered--bottom bg-white">
              <div className="main-container grid">
                  <div className={cx("grid__item v-middle two-twelfths soft-half cursor-pointer delta f-weight-bold",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS})}
                       onClick={this.toggleSubjectFilter}>
                    Quoi ?
                  </div>
                  <div className="grid__item v-middle one-twelfth text--center">•</div>
                  <div className={cx("grid__item v-middle two-twelfths soft-half cursor-pointer delta f-weight-bold",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION})}
                       onClick={this.toggleLocationFilter}>
                    Où ?
                  </div>
                  <div className="grid__item v-middle one-twelfth text--center">•</div>
                  <div className={cx("grid__item v-middle two-twelfths soft-half cursor-pointer delta f-weight-bold",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME})}
                       onClick={this.toggleTimeFilter}>
                    Quand ?
                  </div>
                  <div className="grid__item v-middle one-twelfth text--center">•</div>
                  <div className={cx("grid__item v-middle two-twelfths soft-half cursor-pointer delta f-weight-bold",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.MORE})}
                       onClick={this.toggleMoreFilter}>
                    <i className="fa fa-plus"></i> de filtres
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
