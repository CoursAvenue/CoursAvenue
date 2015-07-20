var FilterActionCreators = require('../../actions/FilterActionCreators'),
    TimeStore            = require('../../stores/TimeStore'),
    TimePicker           = require('./training/TimePicker');
    FluxBoneMixin        = require('../../../mixins/FluxBoneMixin');

var TrainingPanel = React.createClass({

    mixins: [
        FluxBoneMixin('time_store')
    ],

    getInitialState: function getInitialState () {
        return { time_store: TimeStore };
    },

    closePanel: function closePanel () {
        FilterActionCreators.toggleTimeFilter();
    },

    changeContext: function changeContext () {
        FilterActionCreators.changeContext('course');
    },

    render: function render () {
        var start_date = this.state.time_store.get('training_start_date');
        var end_date = this.state.time_store.get('training_end_date');
        return (
            <div className="text--center">
                <div className="inline-block v-middle push-half--right">
                    <TimePicker label="Du" attribute="start_date" initialValue={ start_date } />
                </div>
                <div className="inline-block v-middle">
                    <TimePicker label="Au" attribute="end_date" initialValue={ end_date } />
                </div>
                <div className="text--center relative">
                    <a onClick={ this.closePanel } className='btn btn--blue search-page-filters__button'>OK</a>
                    <a href="javascript:void(0)"
                       className="white absolute north east soft--top f-weight-bold"
                       onClick={this.changeContext}>
                        Voir les cours réguliers
                        <i className="fa fa-chevron-right"></i>
                    </a>
                </div>
            </div>
        );
    },
});

module.exports = TrainingPanel;
