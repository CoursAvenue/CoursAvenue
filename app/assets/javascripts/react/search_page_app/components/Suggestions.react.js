// var
Suggestions = React.createClass({

    showMoreResults: function showMoreResults () {

    },

    render: function render () {
        return (
          <div>
              <h3>Vos critères sont-ils flexibles ?</h3>
              <div className="grid">
                  <div className="grid__item nine-twelfths">
                      Des résultats ne correspondent pas à 100% à votre recherche mais ont été
                      chaudement recommandés par la communauté. Ce serait dommage de ne pas y jeter
                      un oeil, non ?
                  </div>
                  <div className="grid__item three-twelfths">
                      <div className="btn"
                           onClick={this.showMoreResults}>
                          {"> Afficher les suggestions"}
                      </div>
                  </div>
              </div>
          </div>
        );
    }
});

module.exports = Suggestions;
