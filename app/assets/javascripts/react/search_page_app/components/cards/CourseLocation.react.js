var _                  = require('lodash'),
    FluxBoneMixin      = require('../../../mixins/FluxBoneMixin'),
    CardActionCreators = require('../../actions/CardActionCreators'),
    SubjectStore       = require('../../stores/SubjectStore'),
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
        if(!this.props.follow_links) { event.stopPropagation(); event.preventDefault(); }
    },

    url: function url () {
        return CoursAvenue.searchPath({ city: (this.props.card.get('city_slug') || 'paris'),
                                        // using _.get to prevent from error when there is no selected root subject
                                        root_subject_id: _.get(SubjectStore, 'selected_root_subject.slug'),
                                        subject_id: _.get(SubjectStore, 'selected_subject.slug') });

    },

    render: function render () {
        return (<a href={this.url()}
                   className="semi-muted-link block search-page-card__content-bottom-line"
                   onClick={this.highlightMaker}>
                    <i className='fa fa-map-marker-old-style'></i>
                    {this.location()}
                </a>);
    },

    location: function location () {
        return this.addressStr();
        // We can't use distanceStr because we use geoPrecision
        // if (this.state.filter_store.isFilteringAroundLocation()) {
        //     return this.distanceStr();
        // } else {
        //     return this.addressStr();
        // }
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
