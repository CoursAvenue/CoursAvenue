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
            var days = _.map(this.props.weeklyAvailability, function(day, index) {
                var tooltip_content = '';
                var day_before_count = (index == 0 ? 0 : this.props.weeklyAvailability[index - 1].count);
                var day_after_count  = (index == 6 ? 0 : this.props.weeklyAvailability[index + 1].count);
                var classes = classNames({
                    'search-page-card__day-badge--rounded-left' : day_before_count == 0,
                    'search-page-card__day-badge--rounded-right': day_after_count == 0,
                    'search-page-card__day-badge--active'       : day.count > 0,
                    'search-page-card__day-badge'               : true
                });
                if (day.count > 0 && day.start_times && day.start_times.length > 0) {
                    tooltip_content = 'Le ' + I18n.t('day_names_from_english.' + day.day) + ' à ' + day.start_times.join(', ');
                    tooltip_content = tooltip_content.replace(/,\s([^,]+)$/, ' et $1')
                }
                var letter = I18n.t('day_names_from_english.' + day.day)[0].toUpperCase();
                return (
                    <div className={ classes } key={ index }
                         data-toggle='tooltip'
                         data-trigger="hover"
                         data-placement="top"
                         data-title={tooltip_content}>
                    { letter }
                    </div>
                )
            }, this);
            return (<div className="line-height-normal search-page-card__days inline-block">{days}</div>)
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
                return _.capitalize(moment(new Date(date * 1000)).format('dddd DD MMM')); // MMM = month short
            });
            var other_dates = plannings_to_string.splice(1);
            var next_date   = plannings_to_string[0];
            var tooltip_content = (other_dates.length == 0 ? '' : 'Autres dates : ' + other_dates.join(', ').replace(/,\s([^,]+)$/, ' et $1'));
            return (<div data-toggle='tooltip'
                         data-trigger="hover"
                         data-placement="top"
                         data-title={tooltip_content}>
                          {next_date}
                    </div>);
        }
    },

    render: function render () {
        var courseInformation = this.getInformations();
        return (
                <div className='search-page-card__content-bottom-line'>
                    { courseInformation }
                </div>
        )
    },
});

module.exports = CourseInformation;
