var RootSubjectItem       = require('./RootSubjectItem.react'),
    SubjectStore          = require('../stores/SubjectStore'),
    SearchPageDispatcher  = require('../dispatcher/SearchPageDispatcher'),
    FilterActionCreators  = require('../actions/FilterActionCreators'),
    FluxBoneMixin         = require("../../mixins/FluxBoneMixin");

var FilterBar = React.createClass({

    getInitialState: function getInitialState() {
        return { subject_store: SubjectStore }
    },

    searchFullText: function searchFullText (event) {
        FilterActionCreators.searchFullText($(event.currentTarget).val());
    },

    closeFilterPanel: function closeFilterPanel () {
        FilterActionCreators.closeFilterPanel();
    },

    render: function render () {
        return (
          <div className="bg-gray-light soft">
              <div className="inline-block soft-half--right">Ou</div>
              <input className="input--large"
                     size="50"
                     onChange={this.searchFullText}
                     value={this.state.subject_store.full_text_search}
                     placeholder="Recherchez une pratique précise" />
              <div className="btn" onClick={this.closeFilterPanel}>OK</div>
          </div>
        );
    }
});

module.exports = FilterBar;
