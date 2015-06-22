var FilterActionCreators = require('../../actions/FilterActionCreators'),
    TimePicker           = require('./training/TimePicker');

var TrainingPanel = React.createClass({

    closePanel: function closePanel () {
        FilterActionCreators.toggleTimeFilter();
    },

    setDate: function setDate () {
        debugger
    },

    render: function render () {
        return (
            <div>
                <h2>Indiquez vos disponibilités</h2>
                <TimePicker label="Du" />
                <TimePicker label="Au" />
                <a onClick={ this.closePanel } className='btn'>Valider</a>
            </div>
        );
    },
});

module.exports = TrainingPanel;
