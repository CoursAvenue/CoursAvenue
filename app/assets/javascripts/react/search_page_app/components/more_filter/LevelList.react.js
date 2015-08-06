var Selectable          = require('./Selectable'),
    LevelStore          = require('../../stores/LevelStore'),
    LevelActionCreators = require('../../actions/LevelActionCreators');

var LevelList = React.createClass({
    render: function render () {
        var levels = LevelStore.map(function(level, index) {
            return (
                <div key={ level.get('id') } className="push-half--bottom">
                    <Selectable model={ level } toggleSelectionFunc={ LevelActionCreators.toggleLevel } />
                </div>
            );
        });

        return (
            <div>
                <div className="search-page-filter-more__title">Niveau</div>
                <div> { levels } </div>
            </div>
        );
    },
});

module.exports = LevelList;
