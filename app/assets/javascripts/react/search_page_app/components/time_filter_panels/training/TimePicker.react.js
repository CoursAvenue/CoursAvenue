var TimePicker = React.createClass({
    propTypes: {
        label: React.PropTypes.string.isRequired
    },

    setDate: function setDate(event) {
        console.log('changing');
    },

    render: function render () {
        return (
            <div className='soft-half'>
                <label className='inline-block soft-half--right'>
                    { this.props.label }
                </label>
                <input onChange={ this.setDate } />
            </div>
        );
    },
});

module.exports = TimePicker;
