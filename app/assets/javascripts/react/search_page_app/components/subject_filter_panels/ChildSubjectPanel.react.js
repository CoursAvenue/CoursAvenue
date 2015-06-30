var SubjectStore          = require('../../stores/SubjectStore'),
    SearchPageDispatcher  = require('../../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../../mixins/FluxBoneMixin"),
    SubjectItem           = require('../../components/SubjectItem.react'),
    SubjectSearchInput    = require('../../components/SubjectSearchInput.react'),
    FilterActionCreators  = require('../../actions/FilterActionCreators'),
    classNames            = require('classnames');

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
        var group_subject_name = (this.state.subject_store.selected_group_subject ? this.state.subject_store.selected_group_subject.name : '');
        var root_subject_name = (this.state.subject_store.selected_root_subject ? this.state.subject_store.selected_root_subject.name : '');
        return (
          <div>
              <div className="main-container">
                  <ol className="nav breadcrumb text--left">
                      <li>
                          <a onClick={this.showGroupPanel} className="block text--left">Catégorie</a>
                      </li>
                      <li>
                          <a onClick={this.showRootPanel} className="block text--left">Discipline</a>
                      </li>
                      <li>Pratique</li>
                  </ol>
              </div>
              <div className="search-page-filters__title">Choisissez la pratique qui vous plaît</div>
              <div className="main-container soft--bottom">
                  { subject_items }
              </div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
