var SubjectStore          = require('../stores/SubjectStore'),
    RootSubjectItem       = require('../components/RootSubjectItem.react'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin"),
    classNames            = require('classnames');

var SubjectFilter = React.createClass({
    mixins: [
        FluxBoneMixin('subject_store')
    ],

    getInitialState: function getInitialState() {
        return { subject_store: SubjectStore };
    },

    render: function render () {
        var root_subject_items = this.state.subject_store.map(function(subject) {
            return (
              <RootSubjectItem subject={subject} />
            );
        });
        var classes = classNames({
            'north'             : this.state.subject_store.selected,
            'up-north'          : !this.state.subject_store.selected
        });
        return (
          <div className={classes + ' transition-all-300 absolute west one-whole bg-white height-35vh text--center'}>
              <h2>Dans quelle discipline ?</h2>
              <div className="main-container">{root_subject_items}</div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
