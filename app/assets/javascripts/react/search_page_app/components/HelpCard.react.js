var Card               = require('./Card'),
    CardActionCreators = require("../actions/CardActionCreators");

var HelpCard = React.createClass({
    dismiss: function dismiss () {
        CardActionCreators.dismissHelp(this.props.helper);
    },

    render: function render () {
        var options = {
            index: this.props.index,
            classes: this.props.width_class
        };

        return (
            <Card {...options}>
                <div className='bg-white search-page-card__content'>
                    <h4 className="flush text--center soft-half--sides">
                        { this.props.helper.get('name') }
                    </h4>
                </div>
            </Card>
        );
    },
});

module.exports = HelpCard;
