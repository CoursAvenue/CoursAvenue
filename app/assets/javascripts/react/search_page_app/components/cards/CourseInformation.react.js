var classNames = require('classnames'),
    TimeStore  = require('../../stores/TimeStore');

CourseInformation = React.createClass({
    propTypes: {
        courseType:         React.PropTypes.string.isRequired,
        weeklyAvailability: React.PropTypes.array,
        trainings:          React.PropTypes.array
    },

    getInformations: function getInformations () {
        if (this.props.courseType != 'Course::Training') {
            return this.props.weeklyAvailability.map(function(day, index) {
                var tooltip_content = '';
                var classes = classNames({
                    'white':   day.count > 0,
                    'text--center letter-square inline-block v-middle': true,
                    'bg-gray': day.count > 0
                });
                if (day.count > 0 && day.start_times && day.start_times.length > 0) {
                    tooltip_content = 'Le ' + I18n.t('day_names_from_english.' + day.day) + ' à ' + day.start_times.join(', ');
                    tooltip_content = tooltip_content.replace(/,\s([^,]+)$/, ' et $1')
                }
                var letter = I18n.t('day_names_from_english.' + day.day)[0].toUpperCase();
                return (
                    <div style={{ marginLeft: '1px', marginRight: '1px', padding: '2px 0' }}
                    data-toggle='tooltip'
                    data-trigger="hover"
                    data-placement="top"
                    data-title={tooltip_content}
                    className={ classes } key={ index }>
                    { letter }
                    </div>
                )
            });
        } else {
            if (TimeStore.training_start_date) {
                var currentDate = new Date(TimeStore.training_start_date * 1000);
            } else {
                var currentDate = new Date();
            }
            var next_plannings = _.select(this.props.trainings, function(date) {
                var nextDate = new Date(date * 1000);
                return nextDate > currentDate;
            });

            if (next_plannings.length == 0) { return '' };
            var plannings_to_string = _.map(next_plannings, function (date) {
                return _.capitalize(moment(new Date(date * 1000)).format('dddd DD MMMM'));
            });
            var other_dates = plannings_to_string.splice(1);
            var next_date   = plannings_to_string[0];
            var tooltip_content = 'Autres dates : ' + other_dates.join(', ').replace(/,\s([^,]+)$/, ' et $1');
            return (<div data-toggle='tooltip'
                         data-trigger="hover"
                         data-placement="top"
                         data-title={tooltip_content}>
                          {next_date}
                    </div>);
        }
    },

    render: function render () {
        var courseTypeString = (this.props.courseType == 'Course::Training' ? 'Stage / Atelier' : 'Cours');
        var courseInformation = this.getInformations();
        return (
                <div className='very-soft--top very-soft--bottom flexbox'>
                    <div className='flexbox__item v-middle nowrap'>
                        <i className="fa fa-calendar-o very-soft--right"></i>
                        { courseTypeString }
                    </div>
                    <div className='flexbox__item v-middle one-whole text--right'>
                        { courseInformation }
                    </div>
                </div>
        )
    },
});

module.exports = CourseInformation;
