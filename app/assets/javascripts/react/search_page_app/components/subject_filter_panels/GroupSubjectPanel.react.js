var SubjectStore          = require('../../stores/SubjectStore'),
    GroupSubjectItem      = require('../../components/GroupSubjectItem.react'),
    SubjectSearchInput    = require('../../components/SubjectSearchInput.react'),
    SearchPageDispatcher  = require('../../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../../mixins/FluxBoneMixin"),
    classNames            = require('classnames');

var SubjectFilter = React.createClass({
    mixins: [
        FluxBoneMixin('subject_store')
    ],

    getInitialState: function getInitialState() {
        return { subject_store: SubjectStore };
    },

    render: function render () {
        var selected_group_subject_name = "Coucou";
        var group_subject_items = this.state.subject_store.getGroupSubjects().map(function(subject, index) {
            return (
              <GroupSubjectItem subject={ subject } key={ subject.id } />
            );
        });
        return (
          <div className="relative">
              <ol className="search-page-filters__breadcrumbs">
                  <li>Catégorie</li>
              </ol>
              <div className="flexbox search-page-filters__panel-height">
                  {group_subject_items}
              </div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
