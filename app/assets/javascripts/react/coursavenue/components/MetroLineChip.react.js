var classNames = require('classnames');
var MetroLineChip = React.createClass({

    render: function render () {
        var number;
        var metro_classes = classNames({
            'cursor-pointer metro-line metro-line--large transition-all-300': true,
            'metro-line--bis': this.props.line.is_bis,
            'metro-line--selected': this.props.line.selected
        });
        metro_classes += (' ' + this.props.line.line_type + '-line-' + this.props.line.number.replace(' ', '-').toLowerCase());
        if (this.props.line.is_bis) {
            number = (<div>
                          <span className="v-middle">{this.props.line.number.split(' ')[0]}</span>
                          <span className="metro-line__bis">bis</span>
                      </div>);
        } else {
            number = this.props.line.number;
        }
        return (
            <div className={metro_classes}
                 style={ { marginRight: '4px' } }>
                { number }
            </div>
        );
    }
});

module.exports = MetroLineChip;
