var SubjectStore          = require('../../stores/SubjectStore'),
    FilterStore           = require('../../stores/FilterStore'),
    SearchPageDispatcher  = require('../../dispatcher/SearchPageDispatcher'),
    FluxBoneMixin         = require("../../../mixins/FluxBoneMixin"),
    SubjectItem           = require('../../components/SubjectItem.react'),
    FilterActionCreators  = require('../../actions/FilterActionCreators'),
    classNames            = require('classnames');

var SubjectFilter = React.createClass({
    mixins: [
        FluxBoneMixin('subject_store')
    ],

    getInitialState: function getInitialState() {
        return {
          subject_store: SubjectStore,
          filter_store: FilterStore,
        };
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
        return (
          <div>
              <div className="main-container">
                  <a onClick={this.showRootPanel} className="block text--left">Retour</a>
              </div>
              <h2>
                  Quoi ?
                  &gt; {this.state.filter_store.get('group_subject').name}
                  &gt; {this.state.filter_store.get('root_subject').name}
              </h2>
              <div className="main-container">
                  { subject_items }
              </div>
          </div>
        );
    }
});

module.exports = SubjectFilter;
