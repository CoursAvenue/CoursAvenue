var Level      = require('./Level'),
    LevelStore = require('../../stores/LevelStore');

var LevelList = React.createClass({
    render: function render () {
        var levels = LevelStore.map(function(level, index) {
            return (
                <Level level={ level } key={ index } />
            );
        });

        return (
            <div> { levels } </div>
        );
    },
});

module.exports = LevelList;
