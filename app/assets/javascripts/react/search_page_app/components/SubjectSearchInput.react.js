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

    render: function render () {
        var value = this.state.subject_store.full_text_search;
        return (
          <div className={cx("search-page-filters__subject-search",
                            { hidden: (this.state.filter_store.get('current_panel') != FilterPanelConstants.FILTER_PANELS.SUBJECTS) })}>
              <input className="input--large one-whole"
                     value={value}
                     size="50"
                     onChange={this.searchFullText}
                     placeholder="Cherchez une activité..." />
              <i className="fa fa-search beta"></i>
          </div>
        );
    }
});

module.exports = FilterBar;
