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
          subject_store: SubjectStore
        };
    },

    showGroupPanel: function showGroupPanel() {
        FilterActionCreators.showGroupPanel();
    },

    showRootPanel: function showRootPanel() {
        FilterActionCreators.showRootPanel();
    },

    render: function render () {
        var subject_items = SubjectStore.map(function(subject, index) {
            return (
                <SubjectItem subject={ subject.toJSON() } key={index}/>
            );
        });
        subject_item_pages = _.chunk(subject_items, 6);
        subject_item_pages = _.map(subject_item_pages, function(subject_item_page, index) {
            var chunk = _.chunk(subject_item_page, 3)
            return (
              <div className={cx("flexbox search-page-filters__panel-half-height", {
                                  hidden: index > 0 }) }>
                  <div className="flexbox search-page-filters__panel-half-height">
                      { chunk[0] }
                  </div>
                  <div className="flexbox search-page-filters__panel-half-height">
                      { chunk[1] }
                  </div>
              </div>
            );

        });
        var group_subject_name = (this.state.subject_store.selected_group_subject ? this.state.subject_store.selected_group_subject.name : '');
        var root_subject_name = (this.state.subject_store.selected_root_subject ? this.state.subject_store.selected_root_subject.name : '');
        return (
          <div className="relative">
              <ol className="search-page-filters__breadcrumbs">
                  <li>
                      <a onClick={this.showGroupPanel} className="block text--left">Catégorie</a>
                  </li>
                  <li>
                      <a onClick={this.showRootPanel} className="block text--left">Discipline</a>
                  </li>
                  <li>Pratique</li>
              </ol>
              {subject_item_pages}
          </div>
        );
    }
});

module.exports = SubjectFilter;
