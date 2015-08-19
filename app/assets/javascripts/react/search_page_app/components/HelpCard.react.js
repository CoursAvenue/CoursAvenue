var Card               = require('./Card'),
    CardActionCreators = require("../actions/CardActionCreators");

var HelpCard = React.createClass({
    dismiss: function dismiss () {
        CardActionCreators.dismissHelp(this.props.helper);
    },

    toggleDismiss: function toggleDismiss () {
        CardActionCreators.toggleDismiss(this.props.helper);
    },

    callToAction: function callToAction () {
        if (this.props.helper.get('type') == 'info') {
            return (
                <a href={ this.props.helper.get('url') } className='btn btn--blue-info' target='_blank'>
                    { this.props.helper.get('call_to_action') }
                </a>
            );
        } else {
            return '';
        }
    },

    render: function render () {
        var helper = this.props.helper;
        var options = {
            classes: this.props.width_class
        };

        var content_class = 'bg-white search-page-card__content ' + 'search-page-card__content--' +
            helper.get('type');

        return (
            <Card {...options}>
                <div className={ content_class }>
                    <div className='search-page-card__content-top'>
                        <div className='relative'>
                            <div className='search-page-card__dismiss'>
                                <a href='javascript:void(0)' onClick={ this.dismiss }>&times;</a>
                            </div>
                        </div>
                        <div className='text--center giga soft--top'>
                            <i className={ 'fa-card-' + helper.get('type') }></i>
                        </div>
                        <h4 className="flush text--center soft-half caps f-weight-bold">
                            { helper.strType() }
                        </h4>
                    </div>

                    <div className="soft-half--sides soft-half--bottom text--center search-page-card__content-bottom--help">
                        <h4 className='line-height-normal'>{ helper.get('description') }</h4>

                        { this.callToAction() }

                        <div className='text--center soft-half'>
                            <input type='checkbox' className='input--large' id='toggle-dismiss' onChange={ this.toggleDismiss } />
                            <label className='f-weight-bold' for='toggle-dismiss'>Ne plus afficher</label>
                        </div>
                    </div>

                </div>
            </Card>
        );
    },
});

module.exports = HelpCard;
