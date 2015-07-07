var TimeActionCreators = require('../../../actions/TimeActionCreators'),
    TimeStore          = require("../../../stores/TimeStore"),
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

    setDate: function setDate (event) {
        if (event.date) {
            var date = moment(event.date).unix();
        } else {
            date = null;
        }
        TimeActionCreators.setTrainingDate({
            value:     date,
            attribute: this.props.attribute,
        });
    },

    componentDidUpdate: function componentDidUpdate () {
        var time_store_date = this.state.time_store.getTrainingDate(this.props.attribute);
        if (!time_store_date) { return; }
        // Prevent from infinit loop
        if (this.$picker.datepicker('getDate').getTime() == time_store_date.getTime()) { return; }
        this.$picker.datepicker('setDate', time_store_date);
    },

    componentDidMount: function componentDidMount () {
        this.$picker = $(this.getDOMNode()).children('input');
        var options = {
            format: COURSAVENUE.constants.DATE_FORMAT,
            weekStart: 1,
            language: 'fr',
            autoclose: true,
            todayHighlight: true,
            startDate: new Date(),
        };
        this.$picker.datepicker(options);
        this.$picker.on('changeDate', this.setDate);
    },

    render: function render () {
        return (
            <div className='soft-half' data-behavior='datepicker'>
                <label className='inline-block soft-half--right'>
                    { this.props.label }
                </label>
                <input className='datepicker-input' onChange={ this.setDate } value={ this.props.initialValue } />
            </div>
        );
    },
});

module.exports = TimePicker;
