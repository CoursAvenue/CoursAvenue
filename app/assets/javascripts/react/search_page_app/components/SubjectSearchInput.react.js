var SubjectStore             = require('../stores/SubjectStore'),
    SubjectAutocompleteStore = require('../stores/SubjectAutocompleteStore'),
    FilterStore              = require('../stores/FilterStore'),
    SearchPageDispatcher     = require('../dispatcher/SearchPageDispatcher'),
    SubjectActionCreators    = require('../actions/SubjectActionCreators'),
    FilterActionCreators     = require('../actions/FilterActionCreators'),
    FilterPanelConstants     = require('../constants/FilterPanelConstants'),
    cx                       = require('classnames/dedupe');
    FluxBoneMixin            = require("../../mixins/FluxBoneMixin");

var SubjectSearchInput = React.createClass({

    mixins: [
        FluxBoneMixin(['filter_store', 'subject_store'])
    ],

    getInitialState: function getInitialState() {
        return {
            subject_store             : SubjectStore,
            subject_autocomplete_store: SubjectAutocompleteStore,
            filter_store              :  FilterStore
        }
    },

    searchFullText: function searchFullText (event) {
        SubjectActionCreators.searchFullText($(event.currentTarget).val());
    },

    showSearchInputPanel: function showSearchInputPanel (event) {
        if ($(event.currentTarget).val().length > 0) {
            FilterActionCreators.showSearchInputPanel();
        }
    },

    clearFullTextAndCloseSearchInputPanel: function clearFullTextAndCloseSearchInputPanel (event) {
        FilterActionCreators.clearFullTextAndCloseSearchInputPanel();
    },

    selectSubject: function selectSubject (subject) {
        var subject = this.state.subject_autocomplete_store.at(this.state.subject_autocomplete_store.selected_index - 1);
        if (this.props.navigate) {
            window.location = Routes.search_page_path(subject.get('root'), subject.get('slug'), 'paris');
        } else {
            SubjectActionCreators.selectSubject(subject.toJSON());
        }
    },
    executeSearchFullText: function executeSearchFullText () {
        if (this.props.navigate) {
            if (event.metaKey || event.ctrlKey) {
              window.open(Routes.root_search_page_without_subject_path('paris', { discipline: this.state.subject_autocomplete_store.full_text_search }));
            } else {
              window.location = Routes.root_search_page_without_subject_path('paris', { discipline: this.state.subject_autocomplete_store.full_text_search });
            }
        } else {
            FilterActionCreators.searchFullText(this.state.subject_autocomplete_store.full_text_search);
        }
    },

    handleKeyUp: function handleKeyUp (event) {
        // If hitting escape OF there is no val
        if ($(event.currentTarget).val().length == 0 || event.keyCode == 27) {
            this.executeSearchFullText();
            FilterActionCreators.closeFilterPanel();
        // If hitting enter
        } else if (event.keyCode == 13) {
            if (this.state.subject_autocomplete_store.selected_index == 0) {
                this.executeSearchFullText();
                FilterActionCreators.closeFilterPanel();
            } else {
                this.selectSubject()
            }
        // If arrow down
        } else if (event.keyCode == 40) {
            SubjectActionCreators.selectNextSuggestion();
        // If arrow up
        } else if (event.keyCode == 38) {
            SubjectActionCreators.selectPreviousSuggestion();
        }
    },

    shouldComponentUpdate: function shouldComponentUpdate () {
        return (!this.state.subject_store.full_text_search || this.state.subject_store.full_text_search.length == 0);
    },

    componentDidUpdate: function componentDidUpdate () {
        if (!this.state.subject_store.full_text_search || this.state.subject_store.full_text_search.length == 0) {
            $(this.getDOMNode()).find('input').val('');
        }
    },

    render: function render () {
        return (
          <div className="header-search-input palm-one-whole">
              <div className="relative">
                  <input defaultValue={this.state.subject_store.full_text_search}
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
