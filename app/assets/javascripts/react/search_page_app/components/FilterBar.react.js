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
          <div className="text--center relative on-top"
                style={{ marginTop: '-3em' }}>
              <div className="main-container main-container--1000 grid bg-white">
                  <div className={cx("grid__item v-middle three-tenths soft cursor-pointer gamma f-weight-500",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS})}
                       onClick={this.toggleSubjectFilter}>
                    <i className="fa fa-lightbulb-o"></i>&nbsp;Quoi
                  </div>
                  <div className={cx("grid__item v-middle three-tenths soft cursor-pointer gamma f-weight-500",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION})}
                       onClick={this.toggleLocationFilter}>
                    <i className="fa fa-map-marker"></i>&nbsp;Où
                  </div>
                  <div className={cx("grid__item v-middle three-tenths soft cursor-pointer gamma f-weight-500",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME})}
                       onClick={this.toggleTimeFilter}>
                    <i className="fa fa-map-clock"></i>&nbsp;Quand ?
                  </div>
                  <div className={cx("grid__item v-middle one-tenth soft-half cursor-pointer gamma f-weight-500",
                                    { 'bordered--top bordered--thick': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.MORE})}
                       onClick={this.toggleMoreFilter}>
                    <i className="fa fa-filter"></i>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
