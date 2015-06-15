var TimeTable = require('./time_table/TimeTable'),
    FilterStore = require('../../stores/FilterStore');

var LessonPanel = React.createClass({

    getInitialState: function getInitialState () {
        return { timeTable: FilterStore.timeFilters() };
    },

    render: function render () {
        return (
          <div>
              <h2>Quand &gt; Cours Réguliers</h2>
              <h3>Sélectionnez vos disponibilités</h3>

              <TimeTable timeTable={ this.props.timeTable } />
          </div>
        );
    },
});

module.exports = LessonPanel;
