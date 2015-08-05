var MetroMarkerPopup = require('./MetroMarkerPopup.react');
var MapComponent = React.createClass({

    componentDidMount: function componentDidMount () {
        this.createMap();
        this.addMarker()
        if (this.props.home) { this.addHomePlaceMarker(); }
    },

    createMap: function createMap () {
        this.marker_layer = new L.featureGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .setView([this.props.latitude, this.props.longitude], 14)
                          .addLayer(this.marker_layer);
    },

    addMarker: function addMarker () {
        var marker = L.marker([this.props.latitude, this.props.longitude], {
            icon: L.divIcon({
                className: 'map-box-marker map-box-marker__' + this.props.root_subject,
            })
        });
        this.marker_layer.addLayer(marker);
    },

    addHomePlaceMarker: function addHomePlaceMarker () {
        var marker = L.marker([this.props.home.latitude, this.props.home.longitude], {
            icon: L.divIcon({
                className: 'map-box-marker map-box-marker__' + this.props.root_subject,
            })
        });
        var circle = L.circle([this.props.home.latitude, this.props.home.longitude], parseInt(this.props.home.radius, 10) * 1000);
        this.marker_layer.addLayer(circle);
        this.marker_layer.addLayer(marker);
        this.map.fitBounds(this.marker_layer.getBounds().pad(0.3));
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
