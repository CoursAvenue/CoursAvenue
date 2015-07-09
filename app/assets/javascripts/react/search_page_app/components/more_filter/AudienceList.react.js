var Selectable             = require('./Selectable'),
    AudienceStore          = require('../../stores/AudienceStore'),
    AudienceActionCreators = require('../../actions/AudienceActionCreators');

var AudienceList = React.createClass({
    render: function render () {
        var audiences = AudienceStore.map(function(audience, index) {
            return (
                <Selectable model={ audience } toggleSelectionFunc={ AudienceActionCreators.toggleAudience } key={ index } />
            );
        });

        return (
            <div>
                <div>Âge</div>
                <div> { audiences } </div>
            </div>
        )
    },
});

module.exports = AudienceList;
