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
            'north': this.state.subject_store.selected,
            'up-north': !this.state.subject_store.selected,
            'transition-all-300': true,
            'absolute': true,
            'west': true,
            'one-whole': true,
            'bg-white': true,
            'height-35vh': true,
            'text--center': true
        });
        return (
          <div className={classes}>
              <h2>Dans quelle discipline ?</h2>
              <div className="main-container">{root_subject_items}</div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
