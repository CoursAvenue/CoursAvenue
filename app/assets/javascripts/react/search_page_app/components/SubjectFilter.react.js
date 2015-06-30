var SubjectStore                   = require('../stores/SubjectStore'),
    FilterStore                    = require('../stores/FilterStore'),
    LocationStore                  = require('../stores/LocationStore'),
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

    panelToShow: function panelToShow () {
        switch(this.state.filter_store.get('subject_panel')) {
          case FilterPanelConstants.SUBJECT_PANELS.GROUP:
            return ( <SubjectFilterGroupSubjectPanel key='group' /> );
          case FilterPanelConstants.SUBJECT_PANELS.ROOT:
            return ( <SubjectFilterRootSubjectPanel key='root' /> );
          case FilterPanelConstants.SUBJECT_PANELS.CHILD:
            return ( <SubjectFilterChildSubjectPanel key='child' /> );
          default:
            return ( <SubjectFilterGroupSubjectPanel key='group' /> );
        }
    },

    render: function render () {
        var classes = classNames({
            'north'     : (this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS),
            'down-north': !(this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes + ' search-page-filters-wrapper delta soft on-top transition-all-300 absolute west one-whole text--center search-page-filters__subject-panel'}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = SubjectFilter;
