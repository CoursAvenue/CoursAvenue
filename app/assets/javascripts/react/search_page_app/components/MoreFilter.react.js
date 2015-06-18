var FilterActionCreators = require('../actions/FilterActionCreators'),
    FilterPanelConstants = require('../constants/FilterPanelConstants'),
    FilterStore          = require('../stores/FilterStore'),
    AudienceStore        = require('../stores/AudienceStore'),
    FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    AudienceList         = require('./more_filter/AudienceList'),
    PriceSlider          = require('./more_filter/PriceSlider'),
    classNames           = require('classnames');

var MoreFilter = React.createClass({
    mixins: [
        FluxBoneMixin([ 'filter_store', 'audience_store' ]),
    ],

    getInitialState: function getInitialState () {
        return {
            filter_store: FilterStore,
            audience_store: AudienceStore
        };
    },

    closePanel: function closePanel () {
        FilterActionCreators.toggleMoreFilter();
    },

    render: function render () {
        var isCurrentPanel = this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.MORE;
        var classes = classNames('on-top transition-all-300 absolute west one-whole bg-white height-35vh text--center', {
            'north'     : isCurrentPanel,
            'down-north': !isCurrentPanel
        });

        return (
            <div className={ classes } style={ { minHeight: '230px' } }>
              <div>
                  <h2>Filtres supplémentaires</h2>
                  <div className='grid'>
                      <div className='grid__item one-third'>
                          <AudienceList />
                      </div>
                      <div className='grid__item one-third'>
                          <PriceSlider />
                      </div>
                  </div>
                  <a onClick={ this.closePanel } className='btn'>Valider</a>
              </div>
            </div>
        );
    },
});

module.exports = MoreFilter;
