var FilterActionCreators     = require('../actions/FilterActionCreators'),
    SubjectActionCreators    = require('../actions/SubjectActionCreators'),
    FilterPanelConstants     = require('../constants/FilterPanelConstants'),
    FilterStore              = require('../stores/FilterStore'),
    LocationStore            = require('../stores/LocationStore'),
    AutocompleteStore        = require('../stores/AutocompleteStore'),
    FluxBoneMixin            = require("../../mixins/FluxBoneMixin"),
    cx                       = require('classnames/dedupe');

var SubjectAutocompleteFilter = React.createClass({

    mixins: [
        FluxBoneMixin(['autocomplete_store', 'filter_store', 'location_store']),
    ],

    getInitialState: function getInitialState () {
        return {
            autocomplete_store: AutocompleteStore,
            filter_store      : FilterStore,
            location_store    : LocationStore
        };
    },

    hoverResult: function hoverResult (list_name, result_index) {
        return function() {
            SubjectActionCreators.selectSuggestion(list_name, result_index);
        }.bind(this);
    },

    subjects: function subjects () {
        if (!this.state.autocomplete_store.get('subjects')) { return; }
        return this.state.autocomplete_store.get('subjects').map(function(subject, index) {
            return (<div className={cx("flexbox search-page__input-suggestion search-page__input-suggestion--subjects flexbox search-page__input-suggestion--bordered", {
                                      'search-page__input-suggestion--active': (this.state.autocomplete_store.get('selected_index') == index && this.state.autocomplete_store.get('selected_list_name') == 'subjects')
                                    })}
                         onMouseOver={this.hoverResult('subjects', index)}
                         onClick={this.selectSubject}>
                        <div className="flexbox__item visuallyhidden--palm v-middle">
                            <img className="block" height="45" width="80" src={subject.get('small_image_url')} />
                        </div>
                        <div className="flexbox__item v-middle white soft--sides"
                            dangerouslySetInnerHTML={{__html: subject.get('_highlightResult').name.value }}>
                        </div>
                        <div className="flexbox__item v-middle blue-green text--right soft-half--right">
                            <i className="fa fa-chevron-right"></i>
                        </div>
                    </div>)
        }, this);
    },

    selectSubject: function selectSubject (subject) {
        var subject = this.state.autocomplete_store.get('subjects').at(this.state.autocomplete_store.get('selected_index') - 1);
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

    goToStructure: function goToStructure (structure_slug) {
        return function(event) {
            if (event.metaKey || event.ctrlKey) {
                window.open(Routes.structure_path(structure_slug));
            } else {
                window.location = Routes.structure_path(structure_slug);
            }
        }
    },

    structures: function structures () {
        if (!this.state.autocomplete_store.get('structures')) { return; }
        return this.state.autocomplete_store.get('structures').map(function(structure, index) {
            return (<div className={cx("flexbox search-page__input-suggestion search-page__input-suggestion--structures flexbox search-page__input-suggestion--bordered", {
                                      'search-page__input-suggestion--active': (this.state.autocomplete_store.get('selected_index') == index && this.state.autocomplete_store.get('selected_list_name') == 'structures')
                                    })}
                         onMouseOver={this.hoverResult('structures', index)}
                         onClick={this.goToStructure(structure.get('slug'))}>
                        <div className="flexbox__item visuallyhidden--palm v-middle">
                            <img className="block rounded--circle" height="45" width="45" src={structure.get('avatar')} />
                        </div>
                        <div className="flexbox__item one-whole v-middle white soft--sides"
                            dangerouslySetInnerHTML={{__html: structure.get('_highlightResult').name.value }}>
                        </div>
                        <div className="flexbox__item v-middle blue-green text--right soft-half--right">
                            <i className="fa fa-chevron-right"></i>
                        </div>
                    </div>)
        }, this);
    },


    searchFullText: function searchFullText (event) {
        if (this.props.navigate) {
            if (event.metaKey || event.ctrlKey) {
              window.open(Routes.root_search_page_without_subject_path('paris', { discipline: this.state.autocomplete_store.get('full_text_search') }));
            } else {
              window.location = Routes.root_search_page_without_subject_path('paris', { discipline: this.state.autocomplete_store.get('full_text_search') });
            }
        } else {
            FilterActionCreators.searchFullText(this.state.autocomplete_store.get('full_text_search'));
            FilterActionCreators.closeSearchInputPanel();
        }
    },

    render: function render () {
        var full_text_search;
        var height_class = 'search-page-filters__panel-height';
        var current_panel = this.state.filter_store.get('current_panel');
        var classes = cx('west search-page-filters-wrapper search-page-filters__subject-search-panel', {
            'search-page-filters-wrapper--active': (current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen'),
            'search-page-filters-wrapper--fullscreen height-100-percent': (this.props.fullscreen || window.is_mobile)
        });
        if ((this.props.fullscreen || window.is_mobile)) { height_class = 'height-100-percent'; }
        full_text_search = "Tous les cours pour \"" + this.state.autocomplete_store.get('full_text_search') + "\"";
        if (this.state.autocomplete_store.get('total_cards')) {
          full_text_search += " (" + this.state.autocomplete_store.get('total_cards') + ")"
        }
        return (
          <div className={classes}>
              <div className="text--left main-container main-container--1000">
                  <div className={"v-middle input-with-button " + height_class}>
                      <div className={cx("flexbox search-page__input-suggestion search-page__input-suggestion--bordered", {
                                          'search-page__input-suggestion--active': (!this.state.autocomplete_store.get('selected_list_name'))
                                        })}
                           onMouseOver={this.hoverResult(null, 0)}
                           onClick={this.searchFullText}>
                          <div className="flexbox__item v-middle text--center">
                              <i className="fa fa-search white"></i>
                          </div>
                          <div className="flexbox__item v-middle white soft--sides">
                              {full_text_search}
                          </div>
                          <div className="flexbox__item v-middle blue-green text--right soft-half--right">
                              <i className="fa fa-chevron-right"></i>
                          </div>
                      </div>
                      <div className="grid">
                          <div className="grid grid__item two-thirds palm-one-whole">
                              <div className="blue-green f-weight-600 search-page__input-suggestion-label">
                                  DISCIPLINES
                              </div>
                              {this.subjects()}
                          </div>
                          <div className="grid grid__item one-third palm-one-whole">
                              <div className="blue-green f-weight-600 search-page__input-suggestion-label">
                                  PROFESSEURS, ÉCOLES, ASSOCIATIONS
                              </div>
                              {this.structures()}
                          </div>
                      </div>
                  </div>
              </div>

          </div>
        );
    },
});

module.exports = SubjectAutocompleteFilter;
