var MetroLineChip = require('../../components/MetroLineChip.react');

var MarkerPopup = React.createClass({

    propTypes: {
        metro_stop: React.PropTypes.object.isRequired,
    },

    render: function render () {
        var lines = _.map(this.props.metro_stop.lines, function(line) {
            return (<MetroLineChip line={line}/>)
        }.bind(this));
        return (
          <div className="bg-white bordered" style={{ maxHeight: '300px', width: '300px' }}>
              {lines}
              <strong>{this.props.metro_stop.name}</strong>
          </div>
        );
    }
});

module.exports = MarkerPopup;
