var TimeActionCreators = require('../../../actions/TimeActionCreators');

var TimePicker = React.createClass({
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

    componentDidMount: function componentDidMount () {
        var $picker = $(this.getDOMNode()).children('input');
        var options = {
            format: COURSAVENUE.constants.DATE_FORMAT,
            weekStart: 1,
            language: 'fr',
            autoclose: true,
            todayHighlight: true,
            startDate: new Date(),
        };
        $picker.datepicker(options);
        $picker.on('changeDate', this.setDate);
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
