var classNames = require('classnames');

CourseInformation = React.createClass({
    propTypes: {
        courseType:         React.PropTypes.string.isRequired,
        weeklyAvailability: React.PropTypes.array.isRequired
    },

    // TODO: See IndexableCard model.
    render: function render () {
        var courseTypeString = this.props.courseType == '' ? 'Stage / Atelier' : 'Cours';
        var weeklyAvailability = this.props.weeklyAvailability.map(function(day, index) {
            var tooltip_content = '';
            var classes = classNames({
                'white':   day.count > 0,
                'caps':    true,
                'square':  true,
                'bg-gray': day.count > 0
            });
            if (day.count > 0 && day.start_times && day.start_times.length > 0) {
                tooltip_content = 'Le ' + I18n.t('day_names_from_english.' + day.day) + ' à ' + day.start_times.join(', ');
                tooltip_content = tooltip_content.replace(/,\s([^,]+)$/, ' et $1')
            }
            return (
                <span style={{ marginLeft: '1px', marginRight: '1px', paddingLeft: '1px', paddingRight: '1px' }}
                      data-toggle='tooltip'
                      data-trigger="hover"
                      data-placement="top"
                      data-title={tooltip_content}
                      className={ classes } key={ index }>
                    { day.letter }
                </span>
            )
        });
        return (
                <div className='very-soft--top very-soft--bottom grid'>
                    <div className='grid__item one-half'>
                        <i className="fa fa-calendar-o very-soft--right"></i>
                        { courseTypeString }
                    </div>
                    <div className='grid__item one-half text--right'>
                        { weeklyAvailability }
                    </div>
                </div>
        )
    },
});

module.exports = CourseInformation;
