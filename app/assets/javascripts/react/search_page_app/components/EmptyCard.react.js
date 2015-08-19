var Card = require('./Card');

var HelpCard = React.createClass({
    render: function render () {
        var options = { classes: '' };
        return (
            <Card {...options}>
                <div className="bg-white search-page-card__content">
                </div>
            </Card>
        );
    },
});

module.exports = HelpCard;
