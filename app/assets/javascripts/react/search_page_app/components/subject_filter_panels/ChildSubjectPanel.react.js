var _                     = require('lodash'),
    SubjectStore          = require('../../stores/SubjectStore'),
    SearchPageDispatcher  = require('../../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../../mixins/FluxBoneMixin"),
    SubjectItem           = require('../../components/SubjectItem.react'),
    SubjectSearchInput    = require('../../components/SubjectSearchInput.react'),
    FilterActionCreators  = require('../../actions/FilterActionCreators'),
    cx                    = require('classnames/dedupe');

var SubjectFilter = React.createClass({
    mixins: [
        FluxBoneMixin('subject_store')
    ],

    getInitialState: function getInitialState() {
        return {
            page         : 1,
            nb_pages     : 1,
            subject_store: SubjectStore
        };
    },

    showGroupPanel: function showGroupPanel() {
        FilterActionCreators.showGroupPanel();
    },

    showRootPanel: function showRootPanel() {
        FilterActionCreators.showRootPanel();
    },

    goToPage: function goToPage (page) {
        return function (){
            this.setState({ page: page });
        }.bind(this);
    },

    goToPreviousPage: function goToPreviousPage (page) {
        this.setState({ page: this.state.page - 1 });
    },

    goToNextPage: function goToNextPage (page) {
        this.setState({ page: this.state.page + 1 });
    },

    render: function render () {
        var pages_bullet = [];
        var subject_items = SubjectStore.map(function(subject, index) {
            return (
                <SubjectItem subject={ subject.toJSON() } key={index}/>
            );
        });
        subject_item_pages = _.chunk(subject_items, 6);
        subject_item_pages = _.map(subject_item_pages, function(subject_item_page, index) {
            var chunk = _.chunk(subject_item_page, 3)
            pages_bullet.push((<i className={cx("cursor-pointer fa fa-circle search-page-filter__subject-pages-bullet", {
                                               'search-page-filter__subject-pages-bullet--active': (this.state.page == (index + 1))
                                })}
                                   onClick={this.goToPage(index + 1)}></i>));
            return (
              <div className={cx("absolute north west flexbox search-page-filters__panel-half-height search-page-filter__subject-page", {
                                  'search-page-filter__subject-page--active': this.state.page == (index + 1),
                                  'search-page-filter__subject-page-before' : this.state.page < (index + 1),
                                  'search-page-filter__subject-page-after'  : this.state.page > (index + 1),
                              }) }>
                  <div className="flexbox search-page-filters__panel-half-height">
                      { chunk[0] }
                  </div>
                  <div className="flexbox search-page-filters__panel-half-height">
                      { chunk[1] }
                  </div>
              </div>
            );
        }, this);
        this.state.nb_pages = subject_item_pages.length;
        var group_subject_name = (this.state.subject_store.selected_group_subject ? this.state.subject_store.selected_group_subject.name : '');
        var root_subject_name = (this.state.subject_store.selected_root_subject ? this.state.subject_store.selected_root_subject.name : '');
        return (
          <div className="relative text--center search-page-filters__panel-height">
              <ol className="search-page-filters__breadcrumbs">
                  <li>
                      <a onClick={this.showGroupPanel} className="block text--left">Catégorie</a>
                  </li>
                  <li>
                      <a onClick={this.showRootPanel} className="block text--left">Discipline</a>
                  </li>
                  <li>Pratique</li>
              </ol>
              <div>
                  {subject_item_pages}
              </div>
              <div className={cx("search-page-filters__subject-prev absolute push-half--left cursor-pointer white west", {
                                'hidden': (this.state.page == 1)
                              })}
                   onClick={this.goToPreviousPage}>
                  <i className="fa fa-3x fa-chevron-left"></i>
              </div>
              <div className={cx("search-page-filters__subject-next absolute push-half--right cursor-pointer white east", {
                                'hidden': (this.state.page == this.state.nb_pages)
                              })}
                   onClick={this.goToNextPage}>
                  <i className="fa fa-3x fa-chevron-right"></i>
              </div>
              <div className="search-page-filter__subject-pages-bullet-wrapper absolute inline-block white">
                  {pages_bullet}
              </div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
