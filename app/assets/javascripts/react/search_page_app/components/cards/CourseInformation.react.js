var cx = = require('classnames/dedupe');

CourseInformation = React.createClass({
    propTypes: {
        courseType:         React.PropTypes.string.isRequired,
        weeklyAvailability: React.PropTypes.array.isRequired
    },

    render: function render () {
        var courseTypeString = this.props.courseType == '' ? 'Stage / Atelier' : 'Cours';
        var weeklyAvailability = this.props.weeklyAvailability.map(function(day, index) {
            var classes = {
                'white':   true,
                'caps':    true,
                'square':  true,
                'bg-gray': day.count > 0
            }
            return (
                <span className={ classes } key={ index }>
                    { day.letter }
                </span>
            )
        });
        return (
                <div>
                    <i className="fa fa-calendar-o"></i>
                    { courseTypeString }
                    { weeklyAvailability }
                </div>
        )
    },
});

module.exports = CourseInformation;
