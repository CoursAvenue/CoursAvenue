var LessonPlanning = React.createClass({

    propTypes: {
        planning: React.PropTypes.object.isRequired,
    },

    render: function render () {
        return (
            <tr>
                <td data-th="Jour" itemscope="" itemType="http://data-vocabulary.org/Event">
                    <div>
                        <meta content={this.props.course_name} itemprop="summary" />
                        {this.props.planning.date}
                    </div>
                </td>
                <td data-th="Horaire">
                    <div>
                      <time dateTime={this.props.planning.start_date_datetime} itemprop="startDate">
                            {this.props.planning.time_slot}
                      </time>
                      <time dateTime={this.props.planning.end_date_datetime} itemprop="endDate"></time>
                    </div>
                </td>
                <td data-th="Niveau">
                    <div>{this.props.planning.levels}</div>
                </td>
                <td data-th="Public">
                    <div>{this.props.planning.audiences}</div>
                </td>
                <td data-th="Infos">
                    <div data-content={this.props.planning.info}
                         data-html="true"
                         data-toggle="popover"
                         data-trigger="hover">
                        <i class="fa-info"></i>
                    </div>
                </td>
            </tr>
        );
    }
});

module.exports = LessonPlanning;
