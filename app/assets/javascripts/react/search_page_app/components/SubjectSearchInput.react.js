var RootSubjectItem       = require('./RootSubjectItem.react'),
    SubjectStore          = require('../stores/SubjectStore'),
    FilterStore           = require('../stores/FilterStore'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterPanelConstants  = require('../constants/FilterPanelConstants'),
    cx                    = require('classnames/dedupe');
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var FilterBar = React.createClass({

    mixins: [
        FluxBoneMixin(['filter_store', 'subject_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            subject_store: SubjectStore,
            filter_store:  FilterStore
        }
    },

    searchFullText: function searchFullText (event) {
        FilterActionCreators.searchFullText($(event.currentTarget).val());
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    render: function render () {
        var value = this.state.subject_store.full_text_search;
        return (
          <div className={cx("flexbox one-whole absolute north west bg-white",
                            { hidden: (this.state.filter_store.get('current_panel') != FilterPanelConstants.FILTER_PANELS.SUBJECTS) })}>
              <div className="flexbox__item soft-half">
                  <i className="fa fa-search beta"></i>
              </div>
              <div className="flexbox__item soft-half--ends one-whole">
                  <input className="input--large one-whole"
                         value={value}
                         size="50"
                         onChange={this.searchFullText}
                         placeholder="Cherchez une activité..." />
              </div>
              <div className="flexbox__item soft-half text--center" onClick={this.closeFilterPanel}>
                  <i className="fa fa-times beta"></i>
              </div>
          </div>
        );
    }
});

module.exports = FilterBar;
