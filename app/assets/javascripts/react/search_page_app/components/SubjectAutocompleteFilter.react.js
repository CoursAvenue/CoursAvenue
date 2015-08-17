var FilterActionCreators     = require('../actions/FilterActionCreators'),
    SubjectActionCreators    = require('../actions/SubjectActionCreators'),
    FilterPanelConstants     = require('../constants/FilterPanelConstants'),
    FilterStore              = require('../stores/FilterStore'),
    LocationStore            = require('../stores/LocationStore'),
    SubjectAutocompleteStore = require('../stores/SubjectAutocompleteStore'),
    FluxBoneMixin            = require("../../mixins/FluxBoneMixin"),
    cx                       = require('classnames/dedupe');

var SubjectAutocompleteFilter = React.createClass({

    mixins: [
        FluxBoneMixin(['subject_autocomplete_store', 'filter_store', 'location_store']),
    ],

    getInitialState: function getInitialState () {
        return {
            subject_autocomplete_store: SubjectAutocompleteStore,
            filter_store              : FilterStore,
            location_store            : LocationStore
        };
    },

    hoverResult: function hoverResult (result_index) {
        return function() {
            SubjectActionCreators.selectSuggestion(result_index);
        }.bind(this);
    },

    subjects: function subjects () {
        return this.state.subject_autocomplete_store.map(function(subject, index) {
            return (<div className={cx("flexbox search-page__input-suggestion flexbox search-page__input-suggestion--bordered", {
                                      'search-page__input-suggestion--active': this.state.subject_autocomplete_store.selected_index == (index + 1)
                                    })}
                         onMouseOver={this.hoverResult(index + 1)}
                         onClick={this.selectSubject}>
                        <div className="flexbox__item visuallyhidden--palm v-middle">
                            <img className="block" height="45" width="80" src={subject.get('small_image_url')} />
                        </div>
                        <div className="flexbox__item v-middle white soft--sides">
                            {subject.get('name')}
                        </div>
                        <div className="flexbox__item v-middle blue-green text--right soft-half--right">
                            <i className="fa fa-chevron-right"></i>
                        </div>
                    </div>)
        }, this);
    },

    selectSubject: function selectSubject (subject) {
        var subject = this.state.subject_autocomplete_store.at(this.state.subject_autocomplete_store.selected_index - 1);
        if (this.props.navigate) {
            if (event.metaKey || event.ctrlKey) {
              window.open(Routes.search_page_path(subject.get('root'), subject.get('slug'), 'paris'));
            } else {
              window.location = Routes.search_page_path(subject.get('root'), subject.get('slug'), 'paris');
            }
        } else {
            SubjectActionCreators.selectSubject(subject.toJSON());
        }
    },

    searchFullText: function searchFullText (event) {
        if (this.props.navigate) {
            if (event.metaKey || event.ctrlKey) {
              window.open(Routes.root_search_page_without_subject_path('paris', { discipline: this.state.subject_autocomplete_store.full_text_search }));
            } else {
              window.location = Routes.root_search_page_without_subject_path('paris', { discipline: this.state.subject_autocomplete_store.full_text_search });
            }
        } else {
            FilterActionCreators.closeSearchInputPanel();
        }
    },

    render: function render () {

        var height_class = 'search-page-filters__panel-height';
        var current_panel = this.state.filter_store.get('current_panel');
        var classes = cx('west search-page-filters-wrapper search-page-filters__subject-search-panel', {
            'search-page-filters-wrapper--active': (current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen'),
            'search-page-filters-wrapper--fullscreen height-100-percent': (this.props.fullscreen || window.is_mobile)
        });
        var subjects = this.subjects();
        if ((this.props.fullscreen || window.is_mobile)) { height_class = 'height-100-percent'; }
        return (
          <div className={classes}>
              <div className="text--left main-container main-container--1000">
                  <div className={"v-middle input-with-button " + height_class}>
                      <div className={cx("flexbox search-page__input-suggestion search-page__input-suggestion--bordered", {
                                          'search-page__input-suggestion--active': this.state.subject_autocomplete_store.selected_index == 0
                                        })}
                           onMouseOver={this.hoverResult(0)}
                           onClick={this.searchFullText}>
                          <div className="flexbox__item v-middle text--center">
                              <i className="fa fa-search white"></i>
                          </div>
                          <div className="flexbox__item v-middle white soft--sides">
                              Tous les cours pour "{this.state.subject_autocomplete_store.full_text_search}"
                          </div>
                          <div className="flexbox__item v-middle blue-green text--right soft-half--right">
                              <i className="fa fa-chevron-right"></i>
                          </div>
                      </div>
                      <div className="blue-green f-weight-600 search-page__input-suggestion-label">
                          DISCIPLINES
                      </div>
                      {subjects}
                  </div>
              </div>

          </div>
        );
    },
});

module.exports = SubjectAutocompleteFilter;
