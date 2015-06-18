var SubjectStore          = require('../../stores/SubjectStore'),
    RootSubjectItem       = require('../../components/RootSubjectItem.react'),
    SubjectSearchInput    = require('../../components/SubjectSearchInput.react'),
    SearchPageDispatcher  = require('../../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../../mixins/FluxBoneMixin"),
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

    render: function render () {
        var root_subject_items = _.map(this.state.subject_store.getGroupSubject(this.state.subject_store.selected_group_subject.group_id).root_subjects, function(subject, index) {
            return (
                <RootSubjectItem subject={ subject } key={index}/>
            );
        });
        return (
          <div>
              <div className="main-container">
                  <ol className="nav breadcrumb text--left">
                      <li><a onClick={this.showGroupPanel} className="block text--left">Catégorie</a></li>
                      <li>Discipline</li>
                  </ol>
              </div>
              <h2 className="text--center push-half--bottom soft-half--bottom bordered--bottom inline-block">
                  Quelle discipline vous fait envie ?
              </h2>
              <div className="main-container soft--bottom">
                  { root_subject_items }
              </div>
              <SubjectSearchInput />
          </div>
        );
    }
});

module.exports = SubjectFilter;