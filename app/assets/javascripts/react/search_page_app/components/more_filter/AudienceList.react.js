var Audience      = require('./Audience'),
    AudienceStore = require('../../stores/AudienceStore');

var AudienceList = React.createClass({
    render: function render () {
        var audiences = AudienceStore.map(function(audience, index) {
            return (
                <Audience audience={ audience } key={ index } />
            )
        });

        return (
            <div> { audiences } </div>
        )
    },
});

module.exports = AudienceList;
