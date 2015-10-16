var BookPopup             = require('./BookPopup'),
    LocationActionCreator = require('../../coursavenue/actions/LocationActionCreators');
var LessonPlanning = React.createClass({

    propTypes: {
        planning: React.PropTypes.object.isRequired,
        course  : React.PropTypes.object.isRequired
    },

    componentDidMount: function componentDidMount () {
        if (window.location.hash) {
            var planning_id = parseInt(window.location.hash.replace('#', ''), 10);
            if (planning_id == this.props.planning.id) {
                this.bookPlanning();
            }
        }
    },

    bookPlanning: function bookPlanning (event) {
        if (event.target.tagName != 'A') {
            window.location = Routes.checkout_step_1_collection_structures_path();
        }
        // // We generate a random key to make sure a new is created every time.
        // var popup = (<BookPopup planning={this.props.planning}
        //               dont_register_user={this.props.dont_register_user}
        //                           course={this.props.course}
        //                              key={Math.random()}/>);
        // if ($('#mfp-hide').length == 0) { $('body').append('<div id="mfp-hide" class="center-block relative" style="max-width: 530px;">'); }
        // var rendered_popup = React.render(popup, $('#mfp-hide')[0]);
        // $.magnificPopup.open({
        //       items: {
        //           src: rendered_popup.getDOMNode().parentElement,
        //           type: 'inline'
        //       }
        // });
    },

    startDateDatetime: function startDateDatetime () {
        var start_date_datetime = COURSAVENUE.helperMethods.nextWeekDay(this.props.planning.week_day);
        start_date_datetime.hour(this.props.planning.start_hour);
        start_date_datetime.minute(this.props.planning.start_min);
        start_date_datetime.second(0);
        return start_date_datetime.format(COURSAVENUE.constants.DATE_FORMATS.MOMENT_ISO_DATE_8601);
    },

    endDateDatetime: function endDateDatetime () {
        var end_date_datetime = COURSAVENUE.helperMethods.nextWeekDay(this.props.planning.week_day);
        end_date_datetime.hour(this.props.planning.end_hour);
        end_date_datetime.minute(this.props.planning.end_min);
        end_date_datetime.second(0);
        return end_date_datetime.format(COURSAVENUE.constants.DATE_FORMATS.MOMENT_ISO_DATE_8601);
    },

    highlightPlace: function highlightPlace () {
        LocationActionCreator.highlightLocation(this.props.planning.place_id);
    },

    unhighlightPlace: function unhighlightPlace () {
        LocationActionCreator.unhighlightLocation(this.props.planning.place_id);
    },

    render: function render () {
        var location_td, subscribe_button, time, href;
        if (this.props.showSubscribeButton()) {
            // if (this.props.show_planning_link) {
            //     href = Routes.reservation_structure_path(this.props.course.get('structure_slug')) + '#' + this.props.planning.id
            // }
            href = Routes.checkout_step_1_collection_structures_path();
            if (this.props.planning.info) {
                subscribe_button = (<div>
                            <a href={href}
                       data-content={this.props.planning.info}
                          data-html="true"
                        data-toggle="popover"
                       data-trigger="hover"
                                  className="btn btn--full btn--small btn--blue-green">
                                {"M'inscrire"}
                            </a>
                        </div>);
            } else {
                var subscribe_button = (<a href={href}
                                      className="btn btn--full btn--small btn--blue-green">{"M'inscrire"}</a>);
            }
        }
        if (this.props.show_location) {
            location_td = (<td className="two-tenths"><div>{this.props.planning.address_name}</div></td>);
        }
        if (this.props.planning.visible == false) { // Check if false because can be undefined
            time = (<span>(horaire sur demande)</span>);
        } else {
            time = (<span>
                        <time dateTime={this.startDateDatetime()} itemProp="startDate">
                            {this.props.planning.time_slot}
                        </time>
                        <time dateTime={this.endDateDatetime()} itemProp="endDate"></time>
                    </span>);
        }
        return (
            <tr className={ this.props.showSubscribeButton() ? 'cursor-pointer' : '' }
                onMouseLeave={this.unhighlightPlace}
                onMouseEnter={this.highlightPlace}
                onClick={this.props.showSubscribeButton() ? this.bookPlanning : null}>
                <td itemScope=""
                    itemType="http://data-vocabulary.org/Event"
                    className="soft--left nowrap v-middle">
                    <div>
                        <meta content={this.props.course.get('name')} itemProp="summary" />
                        {this.props.planning.date}&nbsp;{ time }
                    </div>
                </td>
                <td className="v-middle">
                    <div>
                        {this.props.planning.levels}
                        <span className="visuallyhidden--lap-and-up">
                            , {this.props.planning.audiences}
                        </span>
                    </div>
                </td>
                <td className="visuallyhidden--palm v-middle">
                    <div>{this.props.planning.audiences}</div>
                </td>
                { location_td }
                <td className={'v-middle ' + (this.props.showSubscribeButton() ? '' : 'hidden')}>
                    { subscribe_button }
                </td>
            </tr>
        );
    }
});

module.exports = LessonPlanning;
