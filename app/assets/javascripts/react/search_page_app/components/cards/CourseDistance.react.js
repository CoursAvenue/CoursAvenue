var _ = require('underscore');

CourseDistance = React.createClass({
    propTypes: {
        rankingInfo: React.PropTypes.object.isRequired,
        address: React.PropTypes.string.isRequired
    },

    render: function render () {
        return (
            <div className='very-soft--top very-soft--bottom'>
                <i className='fa fa-map-marker very-soft--right'></i>
                { this.distanceStr() }
            </div>
        );
    },

    distanceStr: function distanceStr () {
        if (_.isUndefined(this.props.rankingInfo) || _.isEmpty(this.props.rankingInfo)) {
            return this.addressStr();
        }

        var distance = this.props.rankingInfo.geoDistance;
        var string = "À ";
        if (distance > 1000) {
            distance /= 1000.0
            string += distance + " km"
        } else {
            string += distance + " mettres"
        }

        return string;
    },

    addressStr: function addressStr () {
        if (_.isUndefined(this.props.address) || _.isEmpty(this.props.address)) {
            return "";
        }

        // TODO: Truncate string.
        return this.props.address;
    },
});

module.exports = CourseDistance;
