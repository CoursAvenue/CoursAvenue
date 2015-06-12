var SubjectStore          = require('../../stores/SubjectStore'),
    FilterStore           = require('../../stores/FilterStore'),
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
            subject_store: SubjectStore,
            filter_store: FilterStore
        };
    },

    showGroupPanel: function showGroupPanel() {
        FilterActionCreators.showGroupPanel();
    },

    render: function render () {
        var root_subject_items = _.map(SubjectStore.getGroupSubject(this.state.filter_store.get('group_subject').group_id).root_subjects, function(subject, index) {
            return (
                <RootSubjectItem subject={ subject } key={index}/>
            );
        });
        return (
          <div>
              <div className="main-container">
                  <a onClick={this.showGroupPanel} className="block text--left">Retour</a>
              </div>
              <h2>Quoi ? &gt; {this.state.filter_store.get('group_subject').name}</h2>
              <div className="main-container">
                  { root_subject_items }
              </div>
              <hr className="push--ends" />
              <SubjectSearchInput />
          </div>
        );
    }
});

module.exports = SubjectFilter;
