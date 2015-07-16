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

    subjects: function subjects () {
        return this.state.subject_autocomplete_store.map(function(subject) {
            return (<div className="flexbox search-page__input-suggestion flexbox search-page__input-suggestion--bordered"
                         onClick={this.selectSubject(subject)}>
                        <div className="flexbox__item v-middle">
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
        return function() {
            SubjectActionCreators.selectSubject(subject.toJSON());
        }.bind(this);
    },

    searchFullText: function searchFullText (event) {
        FilterActionCreators.closeSearchInputPanel();
    },

    render: function render () {
        var current_panel = this.state.filter_store.get('current_panel');
        var classes = cx('search-page-filters-wrapper search-page-filters__subject-search-panel', {
            'search-page-filters-wrapper--active': (current_panel == FilterPanelConstants.FILTER_PANELS.SUBJECT_FULL_TEXT),
            'search-page-filters-wrapper--full': this.state.location_store.get('fullscreen')
        });
        return (
          <div className={classes}>
              <div className="main-container main-container--1000">
                  <div className="v-middle search-page-filters__panel-height input-with-button">
                      <div className="flexbox search-page__input-suggestion search-page__input-suggestion--bordered search-page__input-suggestion--active"
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
                      {this.subjects()}
                  </div>
              </div>

          </div>
        );
    },
});

module.exports = SubjectAutocompleteFilter;
