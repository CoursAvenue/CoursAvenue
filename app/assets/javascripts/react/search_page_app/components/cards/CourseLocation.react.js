var _                  = require('lodash'),
    FluxBoneMixin      = require('../../../mixins/FluxBoneMixin'),
    CardActionCreators = require('../../actions/CardActionCreators'),
    FilterStore        = require('../../stores/FilterStore');

CourseDistance = React.createClass({
    mixins: [
        FluxBoneMixin('filter_store')
    ],

    propTypes: {
        rankingInfo: React.PropTypes.object,
        address: React.PropTypes.string
    },

    getInitialState: function getInitialState () {
        return {
            filter_store:   FilterStore
        };
    },

    componentDidMount: function componentDidMount () {
        $(this.getDOMNode()).dotdotdot({
            ellipsis : '... ',
            wrap     : 'letter',
            tolerance: 3,
            callback : function callback (is_truncated, original_content) {
                if (is_truncated) {
                    $(this).attr('data-toggle', 'popover')
                             .attr('data-placement', 'top')
                             .attr('data-content', original_content.text());
                }
            }
        });
    },

    highlightMaker: function highlightMaker (event) {
        $.scrollTo(0, { easing: 'easeOutCubic', duration: 350 });
        CardActionCreators.highlightMarker({ event: event, card: this.props.card });
        event.stopPropagation();
    },

    render: function render () {
        return (<a href="javascript:void(0)"
                   className="semi-muted-link block search-page-card__content-bottom-line"
                   onClick={this.highlightMaker}>
                    <i className='fa fa-map-marker-old-style'></i>
                    {this.location()}
                </a>);
    },

    location: function location () {
        if (this.state.filter_store.isFilteringAroundLocation()) {
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
            string += distance + "km"
        } else {
            string += distance + "m"
        }

        return string;
    },

    addressStr: function addressStr () {
        if (_.isUndefined(this.props.address) || _.isEmpty(this.props.address)) {
            return "";
        }

        return this.props.address;
    },
});

module.exports = CourseDistance;
