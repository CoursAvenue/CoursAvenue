var SubjectStore                   = require('../stores/SubjectStore'),
    FilterStore                    = require('../stores/FilterStore'),
    LocationStore                  = require('../stores/LocationStore'),
    SubjectSearchInput             = require('./SubjectSearchInput.react'),
    SubjectFilterGroupSubjectPanel = require('../components/subject_filter_panels/GroupSubjectPanel.react'),
    SubjectFilterRootSubjectPanel  = require('../components/subject_filter_panels/RootSubjectPanel.react'),
    SubjectFilterChildSubjectPanel = require('../components/subject_filter_panels/ChildSubjectPanel.react'),
    SearchPageDispatcher           = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin                  = require("../../mixins/FluxBoneMixin"),
    classNames                     = require('classnames'),
    FilterActionCreators           = require('../actions/FilterActionCreators'),
    FilterPanelConstants           = require('../constants/FilterPanelConstants');

var SubjectFilter = React.createClass({

    mixins: [
        FluxBoneMixin('filter_store')
    ],

    getInitialState: function getInitialState() {
        return {
            filter_store:  FilterStore,
            subject_store: SubjectStore,
            location_store: LocationStore
        };
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    title: function title () {
        switch(this.state.filter_store.get('subject_panel')) {
          case FilterPanelConstants.SUBJECT_PANELS.GROUP:
            return "De quoi avez-vous envie ?";
          case FilterPanelConstants.SUBJECT_PANELS.ROOT:
            return "Quelle discipline vous tente ?";
          case FilterPanelConstants.SUBJECT_PANELS.CHILD:
            return "Choisissez la catégorie d'activité qui vous fait envie";
          default:
            return "De quoi avez-vous envie ?";
        }
    },
    panelToShow: function panelToShow () {
        switch(this.state.filter_store.get('subject_panel')) {
          case FilterPanelConstants.SUBJECT_PANELS.ROOT:
            return ( <SubjectFilterRootSubjectPanel key='root' /> );
          case FilterPanelConstants.SUBJECT_PANELS.CHILD:
            return ( <SubjectFilterChildSubjectPanel key='child' /> );
          case FilterPanelConstants.SUBJECT_PANELS.GROUP:
          default:
            return ( <SubjectFilterGroupSubjectPanel key='group' /> );
        }
    },

    render: function render () {
        var current_panel = this.state.filter_store.get('current_panel');
        var classes = classNames({
            // 'search-page-filters-wrapper--from-right-to-left': (!_.isEmpty(current_panel) && current_panel != FilterPanelConstants.FILTER_PANELS.SUBJECTS),
            'search-page-filters-wrapper--active': (current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECTS),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters-wrapper search-page-filters__subject-panel'}>
              <div className="search-page-filters__title">
                  <SubjectSearchInput />
                  {this.title()}
                  <div className="search-page-filters__closer" onClick={this.closeFilterPanel}>
                      <i className="fa fa-times beta"></i>
                  </div>
              </div>

              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = SubjectFilter;
