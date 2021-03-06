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
        var helper = this.props.helper;

        if (helper.get('type') == 'info') {
            if (helper.get('sign_in')) {
                return (
                    <a href='javascript:void(0)' className='btn btn--blue-info' onClick={ CoursAvenue.signIn }>
                        { helper.get('call_to_action') }
                    </a>
                );
            } else {
                return (
                    <a href={ helper.get('url') } className='btn btn--blue-info' target='_blank'>
                        { helper.get('call_to_action') }
                    </a>
                );
            }
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
                    <div className='search-page-card__content-top relative soft--top'>
                        <div className='search-page-card__dismiss north east absolute'>
                            <a href='javascript:void(0)'
                            onClick={ this.dismiss }
                          className="link-not-outlined">
                                <i className="fa fa-times"></i>
                            </a>
                        </div>
                        <div className='text--center mega soft--top'>
                            <i className={ 'fa-' + helper.get('icon') }></i>
                        </div>
                        <h4 className="flush text--center soft-half caps f-weight-bold">
                            { helper.get('title') }
                        </h4>
                    </div>

                    <div className="soft-half--sides soft-half--bottom text--center search-page-card__content-bottom--help">
                        <h4 dangerouslySetInnerHTML={{__html: helper.get('description') }}></h4>

                        { this.callToAction() }

                    </div>
                    <div className='text--center soft--bottom absolute south left one-whole text--center'>
                        <input type='checkbox' className='v-middle input--large' id='toggle_dismiss' name='toggle_dismiss' onChange={ this.toggleDismiss } />
                        <label className='v-middle f-weight-bold' htmlFor='toggle_dismiss'>Ne plus afficher</label>
                    </div>

                </div>
            </Card>
        );
    },
});

module.exports = HelpCard;
