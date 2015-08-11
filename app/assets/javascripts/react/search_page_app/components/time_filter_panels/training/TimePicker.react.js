var TimeStore          = require("../../../stores/TimeStore"),
    FluxBoneMixin      = require("../../../../mixins/FluxBoneMixin");

var TimePicker = React.createClass({
    mixins: [
        FluxBoneMixin('time_store')
    ],

    getInitialState: function getInitialState() {
        return { time_store: TimeStore };
    },

    propTypes: {
        label:        React.PropTypes.string.isRequired,
        attribute:    React.PropTypes.string.isRequired,
        initialValue: React.PropTypes.string
    },

    render: function render () {
        return (
            <div className='soft-half'>
                <span className='gamma f-weight-600 white inline-block soft-half--right'>
                    { this.props.label }
                </span>
                <input className='input--white input--very-large datepicker-input'
                       data-attribute={ this.props.attribute }
                       value={ this.props.initialValue } />
            </div>
        );
    },
});

module.exports = TimePicker;
