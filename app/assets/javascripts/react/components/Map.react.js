var Map = React.createClass({

    componentDidMount: function componentDidMount () {
        this.marker_layer = new L.featureGroup();

        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .addLayer(this.marker_layer);

        _.each(this.props.markers, function(marker) {
            var mapbox_marker = L.marker([marker.latitude, marker.longitude], {
                icon: L.divIcon({
                    className: 'map-box-marker map-box-marker__' + marker.subject_slug
                })
            });
            this.marker_layer.addLayer(mapbox_marker);
            if (marker.radius) {
                var circle = L.circle([marker.latitude, marker.longitude], parseInt(marker.radius, 10) * 1000);
                this.marker_layer.addLayer(circle);
            }
        }, this);
        if (this.props.markers.length > 0) {
            this.map.fitBounds(this.marker_layer.getBounds().pad(0.3));
            setTimeout(function() { this.map.invalidateSize(); }.bind(this), 100);
        }
    },

    render: function render () {
        return (<div className="google-map"></div>);
    }
});

module.exports = Map;
