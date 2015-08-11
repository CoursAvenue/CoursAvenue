var SubjectStore          = require('../stores/SubjectStore'),
    FilterStore           = require('../stores/FilterStore'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    SubjectActionCreators = require('../actions/SubjectActionCreators'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FilterPanelConstants  = require('../constants/FilterPanelConstants'),
    cx                    = require('classnames/dedupe');
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var SubjectSearchInput = React.createClass({

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

    showSearchInputPanel: function showSearchInputPanel (event) {
        if ($(event.currentTarget).val().length > 0) {
            FilterActionCreators.showSearchInputPanel();
        }
    },

    clearFullTextAndCloseSearchInputPanel: function clearFullTextAndCloseSearchInputPanel (event) {
        FilterActionCreators.clearFullTextAndCloseSearchInputPanel();
    },

    handleKeyUp: function handleKeyUp (event) {
        if ($(event.currentTarget).val().length == 0 || event.keyCode == 27) {
            FilterActionCreators.closeFilterPanel();

        // If hitting enter
        } else if (event.keyCode == 13) {
            SubjectActionCreators.selectHighlightedSuggestion();
        // If arrow down
        } else if (event.keyCode == 40) {
            SubjectActionCreators.selectNextSuggestion();
        // If arrow up
        } else if (event.keyCode == 38) {
            SubjectActionCreators.selectPreviousSuggestion();
        }
    },

    render: function render () {
        var value = this.state.subject_store.full_text_search;
        return (
          <div className="header-search-input palm-one-whole">
              <div className="relative">
                  <input value={value}
                         size="50"
                         onFocus={this.showSearchInputPanel}
                         onKeyUp={this.handleKeyUp}
                         onChange={this.searchFullText}
                         tabIndex="-1"
                         placeholder="Cherchez une activité..." />
                  <i className="fa fa-search"></i>
                  <i className={cx("fa fa-times", { 'hidden': this.state.filter_store.get('current_panel') != FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT }) }
                     onClick={this.clearFullTextAndCloseSearchInputPanel}></i>
              </div>
          </div>);
    }
});

module.exports = SubjectSearchInput;
