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
            filter_store:   FilterStore,
            aroundLocation: FilterStore.isFilteringAroundLocation()
        };
    },

    render: function render () {
        return (
            <div className='very-soft--top very-soft--bottom'>
                <i className='fa fa-map-marker very-soft--right'></i>
                { this.location() }
            </div>
        );
    },

    location: function location () {
        if (this.state.aroundLocation) {
            return this.distanceStr();
        } else {
            return this.addressStr();
        }
    },

    distanceStr: function distanceStr () {
        if (_.isUndefined(this.props.rankingInfo) || _.isEmpty(this.props.rankingInfo)) {
            return ""
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
