var FilterActionCreators = require('../../actions/FilterActionCreators'),
    TimeStore            = require('../../stores/TimeStore'),
    TimePicker           = require('./training/TimePicker'),
    TimeActionCreators   = require('../../actions/TimeActionCreators'),
    FluxBoneMixin        = require('../../../mixins/FluxBoneMixin');

var TrainingPanel = React.createClass({

    mixins: [
        FluxBoneMixin('time_store')
    ],

    getInitialState: function getInitialState () {
        return { time_store: TimeStore };
    },

    componentDidMount: function componentDidMount () {
        COURSAVENUE.datepicker_initializer();
        $datepicker = $(this.getDOMNode()).find('[data-behavior=datepicker]');
        $datepicker.on("changeDate", this.setDate);
        $datepicker.on("clearDate", this.clearDate);
        this.$start_picker = $(this.getDOMNode()).find('[data-attribute=start_date]');
        this.$end_picker   = $(this.getDOMNode()).find('[data-attribute=end_date]');
    },

    closePanel: function closePanel () {
        FilterActionCreators.toggleTimeFilter();
    },

    changeContext: function changeContext () {
        FilterActionCreators.changeContext('course');
    },

    clearDate: function clearDate (event) {
        var attribute = event.target.dataset.attribute;
        if (attribute == 'start_date') {
            this.$end_picker.datepicker('setStartDate', new Date());
        }
        TimeActionCreators.setTrainingDate({
            value:     null,
            attribute: attribute
        });
    },

    setDate: function setDate (event) {
        var attribute, date;
        if (event.date) {
            date = moment(event.date).unix();
        }
        attribute = event.target.dataset.attribute;
        // If setting the start date, changing end start date of second datepicker
        if (attribute == 'start_date') {
            this.$end_picker.datepicker('setStartDate', event.date);
        }
        TimeActionCreators.setTrainingDate({
            value:     date,
            attribute: attribute
        });
    },

    render: function render () {
        var start_date = this.state.time_store.get('training_start_date');
        var end_date = this.state.time_store.get('training_end_date');
        return (
            <div className="text--center">
                <div data-behavior="datepicker"
                     className="input-daterange"
                     data-start-date={moment().format('DD-MM-YYYY')}
                     data-clear-btn={"true"}>
                    <div className="inline-block v-middle push-half--right">
                        <TimePicker label="Du" attribute="start_date" initialValue={ start_date } />
                    </div>
                    <div className="inline-block v-middle">
                        <TimePicker label="Au" attribute="end_date" initialValue={ end_date } />
                    </div>
                </div>
                <div className="text--center relative">
                    <a onClick={ this.closePanel } className='btn btn--blue search-page-filters__button'>OK</a>
                    <a tabIndex="-1" href="javascript:void(0)"
                       className="white absolute north east soft--top f-weight-bold"
                       onClick={this.changeContext}>
                        Voir les cours réguliers
                        <i className="fa fa-chevron-right soft-half--left milli"></i>
                    </a>
                </div>
            </div>
        );
    },
});

module.exports = TrainingPanel;
