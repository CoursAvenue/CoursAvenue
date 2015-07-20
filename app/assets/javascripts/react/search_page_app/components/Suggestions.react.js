var FilterActionCreators = require('../actions/FilterActionCreators');

Suggestions = React.createClass({

    showMoreResults: function showMoreResults () {
        FilterActionCreators.clearAllTheData();
        FilterActionCreators.search();
    },

    render: function render () {
        return (
          <div className="soft-double bg-blue-green white">
              <div className="grid">
                  <div className="grid__item palm-one-whole v-middle eight-twelfths">
                      <h3 className="flush">Vos critères sont-ils flexibles ?</h3>
                      <div className="epsilon line-height-1-5">
                          Des résultats ne correspondent pas à 100% à votre recherche mais ont été
                          chaudement recommandés par la communauté. Ce serait dommage de ne pas y jeter
                          un oeil, non ?
                      </div>
                  </div>
                  <div className="grid__item palm-one-whole palm-text--center v-middle four-twelfths text--right">
                      <div className="btn btn--blue-green"
                           onClick={this.showMoreResults}>
                          Afficher les suggestions
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Suggestions;
