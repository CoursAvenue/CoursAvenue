var cx = require('classnames');

var Selectable = React.createClass({
    propTypes: {
        model: React.PropTypes.object.isRequired,
        toggleSelectionFunc: React.PropTypes.func.isRequired,
    },

    toggleSelected: function toggleSelected () {
        this.props.toggleSelectionFunc(this.props.model);
    },

    render: function render () {
        var classes = cx('btn', {
            'btn--gray': this.props.model.get('selected'),
        });

        return (
            <div onClick={ this.toggleSelected } className={ classes }>
                { this.props.model.get('name') }
            </div>
        )
    },
});

module.exports = Selectable;
