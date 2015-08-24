var PriceGroup = React.createClass({

    getRows: function getRows (prices) {
        return _.map(prices, function(price, index) {
            var amount;
            if (price.amount && price.promo_amount) {
                amount = (<div>
                              <span className="line-through">{COURSAVENUE.helperMethods.readableAmount(price.amount)}</span>
                              &nbsp;<span>{COURSAVENUE.helperMethods.readableAmount(price.promo_amount)}</span>
                          </div>);
            } else if (price.amount) {
                amount = (<span>{COURSAVENUE.helperMethods.readableAmount(price.amount)}</span>);
            } else if (price.promo_amount) {
                amount = (<span>{COURSAVENUE.helperMethods.readableAmount(price.promo_amount, (price.promo_amount_type || '€'))}</span>);
            }
            return (<tr key={ index }>
                        <td className='soft--left' data-th="Formule">
                              <div>
                                  { price.libelle }&nbsp;
                                  { (price.info ? '(' + price.info + ')' : '') }
                              </div>
                        </td>
                        <td className="text--right soft--right" data-th='Tarif'>
                              <div>{amount}</div>
                        </td>
                  </tr>);
        }, this);
    },

    render: function render () {
        var grouped_prices = _.groupBy(this.props.prices, function(price) {
            return price.type;
        });

        return (<table className='table--striped table--data table-responsive flush'>
                    <thead>
                        <tr>
                            <th className='soft--left ten-twelfths'>Formule</th>
                            <th className='two-twelfths text--right soft--right'>Tarif</th>
                        </tr>
                    </thead>
                    <tbody>
                        {this.getRows(grouped_prices['Price::BookTicket'])}
                        {this.getRows(grouped_prices['Price::Subscription'])}
                        {this.getRows(grouped_prices['Price::Registration'])}
                        {this.getRows(grouped_prices['Price::PremiumOffer'])}
                        {this.getRows(grouped_prices['Price::Discount'])}
                    </tbody>
                </table>
);
    }
});

module.exports = PriceGroup;
