var MarkerPopup = React.createClass({

    propTypes: {
        metro_stop: React.PropTypes.object.isRequired,
    },

    render: function render () {
        var lines = [];
        _.each(this.props.metro_stop.lines, function(line) {
            var number;
            if (line.is_bis) {
                number = (<div>
                              <span className="v-middle">{line.number_without_bis}</span>
                              <span className="metro-line-bis">bis</span>
                          </div>);
            } else {
                number = line.number;
            }
            lines.push((<div className={'metro-line metro-line-' + line.number}>
                          {number}
                        </div>));
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
