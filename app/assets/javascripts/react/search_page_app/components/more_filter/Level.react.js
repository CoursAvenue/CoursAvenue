var cx                  = require('classnames'),
    LevelActionCreators = require('../../actions/LevelActionCreators');

// TODO: DRY this and the Audience component.
var Level = React.createClass({
    propTypes: {
        level: React.PropTypes.object.isRequired,
    },

    toggleSelected: function toggleSelected () {
        LevelActionCreators.toggleLevel(this.props.level);
    },

    render: function render () {
        var classes = cx('cursor-pointer', {
            'bg-gray': this.props.level.get('selected'),
        });

        return (
            <div onClick={ this.toggleSelected } className={ classes }>
                { this.props.level.get('name') }
            </div>
        )
    },
});

module.exports = Level;
