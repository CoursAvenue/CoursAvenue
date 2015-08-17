var FilterActionCreators = require('../actions/FilterActionCreators'),
    FilterPanelConstants = require('../constants/FilterPanelConstants'),
    FilterStore          = require('../stores/FilterStore'),
    LocationStore        = require('../stores/LocationStore'),
    AudienceStore        = require('../stores/AudienceStore'),
    LevelStore           = require('../stores/LevelStore'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    AudienceList         = require('./more_filter/AudienceList'),
    PriceSlider          = require('./more_filter/PriceSlider'),
    LevelList            = require('./more_filter/LevelList'),
    classNames           = require('classnames');

var MoreFilter = React.createClass({
    mixins: [
        FluxBoneMixin(['filter_store', 'audience_store', 'level_store']),
    ],

    getInitialState: function getInitialState () {
        return {
            filter_store  : FilterStore,
            audience_store: AudienceStore,
            level_store   : LevelStore,
            location_store: LocationStore,
        };
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.toggleMoreFilter();
    },

    render: function render () {
        var current_panel = this.state.filter_store.get('current_panel');
        var classes = classNames({
            'search-page-filters-wrapper--from-right-to-left': (current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECTS
                                                             || current_panel == FilterPanelConstants.FILTER_PANELS.LOCATION
                                                             || current_panel == FilterPanelConstants.FILTER_PANELS.TIME),
            'search-page-filters-wrapper--active': (current_panel == FilterPanelConstants.FILTER_PANELS.MORE),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters-wrapper search-page-filters__more-panel'}>
              <div className="search-page-filters__title">
                  Filtres supplémentaires
                  <div className="search-page-filters__closer" onClick={this.closeFilterPanel}>
                      <i className="fa fa-times-big"></i>
                  </div>
              </div>
              <div className="flexbox relative">
                  <div className="flexbox__item text--center v-middle search-page-filters__panel-height">
                      <div className="search-page-filters__image-button-curtain"></div>
                          <div className="main-container main-container--1000 relative">
                              <div className='flexbox'>
                                  <div className='flexbox__item v-top one-third'>
                                      <AudienceList />
                                  </div>
                                  <div className='flexbox__item soft--sides v-top bordered--sides border-color-black-transparent one-third'>
                                      <PriceSlider />
                                  </div>
                                  <div className='flexbox__item soft--sides v-top one-third'>
                                      <LevelList />
                                  </div>
                              </div>
                              <div className='text--center'>
                                  <a onClick={ this.closeFilterPanel } className='btn btn--blue-green border-none search-page-filters__button'>OK</a>
                              </div>
                          </div>
                      </div>
                  </div>
              </div>
        );
    },
});

module.exports = MoreFilter;
