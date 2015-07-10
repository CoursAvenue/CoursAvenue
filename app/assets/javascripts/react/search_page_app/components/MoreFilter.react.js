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

    closePanel: function closePanel () {
        FilterActionCreators.toggleMoreFilter();
    },

    render: function render () {
        var classes = classNames({
            'search-page-filters-wrapper--active': (this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.MORE),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters-wrapper search-page-filters__more-panel'}>
              <div className="search-page-filters__title">
                  Filtres supplémentaires
                  <div className="search-page-filters__closer" onClick={this.closeFilterPanel}>
                      <i className="fa fa-times beta"></i>
                  </div>
              </div>
              <div>
                  <div className='grid'>
                      <div className='grid__item one-third'>
                          <AudienceList />
                      </div>
                      <div className='grid__item one-third'>
                          <PriceSlider />
                      </div>
                      <div className='grid__item one-third'>
                          <LevelList />
                      </div>
                  </div>
                  <a onClick={ this.closePanel } className='btn'>Valider</a>
              </div>
            </div>
        );
    },
});

module.exports = MoreFilter;
