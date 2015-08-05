var Selectable             = require('./Selectable'),
    AudienceStore          = require('../../stores/AudienceStore'),
    AudienceActionCreators = require('../../actions/AudienceActionCreators');

var AudienceList = React.createClass({
    render: function render () {
        var audiences = AudienceStore.map(function(audience, index) {
            return (
                <div className="push-half--bottom">
                    <Selectable model={ audience } toggleSelectionFunc={ AudienceActionCreators.toggleAudience } key={ index } />
                </div>
            );
        });

        return (
            <div>
                <div className="search-page-filter-more__title">Âge</div>
                <div> { audiences } </div>
            </div>
        )
    },
});

module.exports = AudienceList;
