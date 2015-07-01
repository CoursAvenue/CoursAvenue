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

    render: function render () {
        var info = '';
        if (this.props.planning.info) {
            info = (<div data-content={this.props.planning.info}
                         data-html="true"
                         data-toggle="popover"
                         data-trigger="hover">
                        <i className="fa-info"></i>
                    </div>);
        }
        return (
            <tr className="cursor-pointer" onClick={this.bookPlanning}>
                <td data-th="Jour" itemScope="" itemType="http://data-vocabulary.org/Event">
                    <div>
                        <meta content={this.props.course.name} itemprop="summary" />
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
                    {info}
                </td>
            </tr>
        );
    }
});

module.exports = LessonPlanning;
