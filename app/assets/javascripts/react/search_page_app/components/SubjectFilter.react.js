var SubjectStore                   = require('../stores/SubjectStore'),
    FilterStore                    = require('../stores/FilterStore'),
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
            subject_store: SubjectStore
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
            'down-north': !(this.state.filter_store.get('current_panel') == FilterPanelConstants.FILTER_PANELS.SUBJECTS)
        });
        return (
          <div className={classes + ' transition-all-300 absolute west one-whole bg-white height-35vh text--center'}
               style={{ minHeight: '230px'}}>
              { this.panelToShow() }
          </div>
        );
    }
});

module.exports = SubjectFilter;
