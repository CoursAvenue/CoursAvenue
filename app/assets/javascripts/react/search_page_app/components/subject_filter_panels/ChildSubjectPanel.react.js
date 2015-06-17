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
                  &gt; {this.state.subject_store.selected_group_subject.name}
                  &gt; {this.state.subject_store.selected_root_subject.name}
              </h2>
              <div className="main-container">
                  { subject_items }
              </div>
              <hr className="push--ends" />
              <SubjectSearchInput />
          </div>
        );
    }
});

module.exports = SubjectFilter;
