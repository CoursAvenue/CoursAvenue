var MetroMarkerPopup = require('./MetroMarkerPopup.react');
var MapComponent = React.createClass({

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        this.createMap();
        this.addMarker()
    },

    createMap: function createMap () {
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .setView([this.props.latitude, this.props.longitude], 14);
    },

    addMarker: function addMarker () {
        var marker = L.marker([this.props.latitude, this.props.longitude], {
            icon: L.divIcon({ className: 'map-box-marker on-top' })
        });
        this.map.addLayer(marker);
    },

    render: function render () {
        var map_style = {
            minHeight: '230px',
            height: '100%'
        };
        return (
          <div style={map_style}></div>
        );
    }
});

module.exports = MapComponent;
