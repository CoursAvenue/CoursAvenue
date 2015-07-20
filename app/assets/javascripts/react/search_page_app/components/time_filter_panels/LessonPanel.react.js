var TimeTable            = require('./time_table/TimeTable'),
    TimeStore            = require('../../stores/TimeStore'),
    FilterActionCreators = require('../../actions/FilterActionCreators'),
    FluxBoneMixin        = require('../../../mixins/FluxBoneMixin');

var LessonPanel = React.createClass({

    mixins: [
        FluxBoneMixin('time_table')
    ],

    getInitialState: function getInitialState () {
        return { time_table: TimeStore };
    },

    closePanel: function closePanel () {
        FilterActionCreators.toggleTimeFilter();
    },

    changeContext: function changeContext () {
        FilterActionCreators.changeContext('training');
    },

    render: function render () {
        return (<div>
                    <div className="push--bottom">
                        <TimeTable timeTable={ this.state.time_table } />
                    </div>
                    <div className="text--center relative">
                        <a onClick={ this.closePanel } className='btn btn--blue search-page-filters__button'>OK</a>
                        <a href="javascript:void(0)"
                           className="white absolute north east soft--top f-weight-bold"
                           onClick={this.changeContext}>
                            Voir les stages & ateliers
                            <i className="fa fa-chevron-right"></i>
                        </a>
                    </div>
                </div>
        );
    },
});

module.exports = LessonPanel;
