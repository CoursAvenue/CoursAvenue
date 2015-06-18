var cx                     = require('classnames'),
    AudienceActionCreators = require('../../actions/AudienceActionCreators');

var Audience = React.createClass({
    propTypes: {
        audience: React.PropTypes.object.isRequired,
    },

    toggleSelected: function toggleSelected () {
        AudienceActionCreators.toggleAudience(this.props.audience);
    },

    render: function render () {
        var classes = cx('cursor-pointer', {
            'bg-gray': this.props.audience.get('selected'),
        });

        return (
            <div onClick={ this.toggleSelected } className={ classes }>
                { this.props.audience.get('name') }
            </div>
        )
    },
});

module.exports = Audience;
