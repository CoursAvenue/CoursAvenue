var _             = require('underscore'),
    FluxBoneMixin = require('../../../mixins/FluxBoneMixin'),
    FilterStore   = require('../../stores/FilterStore');

CourseDistance = React.createClass({
    mixins: [
        FluxBoneMixin('filter_store')
    ],

    propTypes: {
        rankingInfo: React.PropTypes.object.isRequired,
        address: React.PropTypes.string.isRequired
    },

    getInitialState: function getInitialState () {
        return {
            filter_store:   FilterStore
        };
    },

    render: function render () {
        return (
            <div className='very-soft--top very-soft--bottom'>
                <div dangerouslySetInnerHTML={{__html: this.location() }} />
            </div>
        );
    },

    location: function location () {
        if (this.state.filter_store.isFilteringAroundLocation()) {
            return "<i class='fa fa-map-marker very-soft--right'></i> " + this.distanceStr();
        } else {
            return "<i class='fa fa-map-marker very-soft--right'></i> " + this.addressStr();
        }
    },

    distanceStr: function distanceStr () {
        if (_.isUndefined(this.props.rankingInfo) || _.isEmpty(this.props.rankingInfo)) {
            return ""
        }

        var distance = this.props.rankingInfo.geoDistance;
        var string = "À ";
        var minutes_by_walk = (distance / 100)
        if (distance > 1000) {
            distance /= 1000.0
            string += distance + "km"
        } else {
            string += distance + "m"
        }
        if (minutes_by_walk < 20) {
            string += ' (~' + minutes_by_walk + 'min <i class="fa-walk"></i>)'
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
