var SubjectStore          = require('../stores/SubjectStore'),
    SubjectListItem       = require('../components/SubjectListItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var SubjectList = React.createClass({
    mixins: [
        FluxBoneMixin('subject_store')
    ],

    getInitialState: function getInitialState() {
        return { subject_store: SubjectStore };
    },

    render: function render () {
        var subject_list_items = this.state.subject_store.map(function(subject) {
            return (
              <SubjectListItem subject={subject} />
            );
        });
        return (
          <div>
              <h1>Disciplines</h1>
              {subject_list_items}
          </div>
        );
    }
});

module.exports = SubjectList;
