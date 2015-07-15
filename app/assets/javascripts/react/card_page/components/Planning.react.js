var BookPopup = require('./BookPopup');
var LessonPlanning = React.createClass({

    propTypes: {
        planning: React.PropTypes.object.isRequired,
        course  : React.PropTypes.object.isRequired
    },

    bookPlanning: function bookPlanning () {
        var popup = (<BookPopup planning={this.props.planning} course={this.props.course}/>);
        var rendered_popup = React.render(popup, $('#mfp-hide')[0]);
        $.magnificPopup.open({
              items: {
                  src: rendered_popup.getDOMNode().parentElement,
                  type: 'inline'
              }
        });
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
    render: function render () {
        var info = '';
        if (this.props.planning.info) {
            info = (<div>
                        <div className="visuallyhidden--lap-and-up">
                            <i>{this.props.planning.info}</i>
                        </div>
                        <div data-content={this.props.planning.info}
                             data-html="true"
                             data-toggle="popover"
                             data-trigger="hover"
                             className="visuallyhidden--palm">
                            <i className="fa-info"></i>
                        </div>
                    </div>);
        }
        return (
            <tr className="cursor-pointer" onClick={this.bookPlanning}>
                <td itemScope="" itemType="http://data-vocabulary.org/Event">
                    <div>
                        <meta content={this.props.course.name} itemprop="summary" />
                        {this.props.planning.date}
                        <span className="visuallyhidden--lap-and-up">{this.props.planning.time_slot}</span>
                    </div>
                </td>
                <td className="visuallyhidden--palm">
                    <div>
                        <time dateTime={this.startDateDatetime()} itemprop="startDate">
                            {this.props.planning.time_slot}
                        </time>
                        <time dateTime={this.endDateDatetime()} itemprop="endDate"></time>
                    </div>
                </td>
                <td>
                    <div>
                        {this.props.planning.levels}
                        <span className="visuallyhidden--lap-and-up">
                            , {this.props.planning.audiences}
                        </span>
                    </div>
                </td>
                <td className="visuallyhidden--palm">
                    <div>{this.props.planning.audiences}</div>
                </td>
                <td>
                    {info}
                </td>
                <td>
                    <strong className="btn btn--full btn--small btn--green">Réserver</strong>
                </td>
            </tr>
        );
    }
});

module.exports = LessonPlanning;
