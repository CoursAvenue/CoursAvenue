var _ = require('underscore');

CourseDistance = React.createClass({
    propTypes: {
        rankingInfo: React.PropTypes.object.isRequired
    },

    render: function render () {
        return (
            <div className='bordered--top very-soft--top very-soft--bottom'>
                <i className='fa fa-map-marker very-soft--right'></i>
                { this.distanceStr() }
            </div>
        );
    },

    distanceStr: function distanceStr () {
        if (_.isUndefined(this.props.rankingInfo) || _.isEmpty(this.props.rankingInfo)) {
            return "";
        }

        var distance = this.props.rankingInfo.geoDistance;
        var string = "À ";
        if (distance > 1000) {
            distance /= 1000.0
            string += distance + " kms"
        } else {
            string += distance + " mettres"
        }

        return string;
    },
});

module.exports = CourseDistance;
