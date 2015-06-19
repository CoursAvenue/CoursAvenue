var Selectable          = require('./Selectable'),
    LevelStore          = require('../../stores/LevelStore'),
    LevelActionCreators = require('../../actions/LevelActionCreators');

var LevelList = React.createClass({
    render: function render () {
        var levels = LevelStore.map(function(level, index) {
            return (
                <Selectable model={ level } toggleSelectionFunc={ LevelActionCreators.toggleLevel } key={ index } />
            );
        });

        return (
            <div>
                <div>Niveau</div>
                <div> { levels } </div>
            </div>
        );
    },
});

module.exports = LevelList;
