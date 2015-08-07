var RootSubjectItem       = require('./RootSubjectItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterStore           = require('../stores/FilterStore'),
    CardStore             = require('../stores/CardStore'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin"),
    cx                    = require('classnames/dedupe'),
    FilterPanelConstants  = require('../constants/FilterPanelConstants');

var FilterBar = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store: FilterStore,
            card_store: CardStore
        };
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
          <div className="search-page-filter-bar-wrapper grid--full visuallyhidden--palm">
              <div className={ cx("grid__item search-page-filter search-page-filter--subject three-tenths",
                                { 'search-page-filter--active': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS,
                                  'search-page-filter--has-filters': this.state.card_store.hasActiveFilters('subject') }) }
                   onClick={this.toggleSubjectFilter}>
                <div className="search-page-filter__icon relative inline-block v-middle">
                    <i className="v-middle fa fa-chevron-up"></i>
                    <i className="v-middle fa fa-question-circle"></i>
                </div>
                <div className="inline-block v-middle">
                    Quoi
                </div>
              </div>
              <div className={cx("grid__item search-page-filter search-page-filter--location three-tenths",
                                { 'search-page-filter--active': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.LOCATION,
                                  'search-page-filter--has-filters': this.state.card_store.hasActiveFilters('location') }) }
                   onClick={this.toggleLocationFilter}>
                  <div className="search-page-filter__icon relative inline-block v-middle">
                      <i className="v-middle fa fa-chevron-up"></i>
                      <i className="v-middle fa fa-map-marker"></i>
                  </div>
                  <div className="inline-block v-middle">
                      Où
                  </div>
              </div>
              <div className={cx("grid__item search-page-filter search-page-filter--time three-tenths",
                                { 'search-page-filter--active': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.TIME,
                                  'search-page-filter--has-filters': this.state.card_store.hasActiveFilters('time') }) }
                   onClick={this.toggleTimeFilter}>
                  <div className="search-page-filter__icon relative inline-block v-middle">
                      <i className="v-middle fa fa-chevron-up"></i>
                      <i className="v-middle fa fa-clock"></i>
                  </div>
                  <div className="inline-block v-middle">
                      Quand
                  </div>
              </div>
              <div className={cx("grid__item one-tenth search-page-filter search-page-filter--more",
                               { 'search-page-filter--active': this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.MORE,
                                 'search-page-filter--has-filters': this.state.card_store.hasActiveFilters('more') }) }
                   onClick={this.toggleMoreFilter}>
                  <div className="search-page-filter__icon relative inline-block v-middle">
                      <i className="v-middle fa fa-chevron-up"></i>
                      <i className="v-middle fa fa-more-filters"></i>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
