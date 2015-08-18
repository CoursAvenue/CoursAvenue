var LocationStore          = require('../stores/LocationStore'),
    LocationActionCreators = require('../actions/LocationActionCreators');

var Map = React.createClass({

    getInitialState: function getInitialState() {
        return { location_store: LocationStore };
    },

    componentDidMount: function componentDidMount () {
        this.circle_layer = new L.featureGroup();
        this.marker_layer = new L.featureGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .addLayer(this.marker_layer)
                          .addLayer(this.circle_layer);

        this.state.location_store.on('reset', this.addMarkers);
        this.state.location_store.on('change:highlighted', this.highlightMarker);

        LocationActionCreators.bootstrapLocations(this.props.markers);
    },

    // Make all marker a little transparent but not highlighted one.
    highlightMarker: function highlightMarker (location) {
        var location_id     = location.get('id');
        if (location.get('highlighted')) {
            _.each(this.marker_layer.getLayers(), function(marker) {
                if (marker.id != location_id) {
                    marker.setOpacity(0.3);
                    marker.setZIndexOffset(1000);
                } else {
                    marker.setZIndexOffset(10000);
                }
            }, this);
        } else {
            _.each(this.marker_layer.getLayers(), function(marker) {
                marker.setOpacity(1);
            });
        }
    },

    addMarkers: function addMarkers () {
        this.state.location_store.map(function(marker, index) {
            var icon_options = { className: 'map-box-marker map-box-marker__' + marker.get('subject_slug') }
            if (!this.props.hide_numbers) {
                icon_options.html = '<div>' +  (index + 1) + '</div>';
            }
            var mapbox_marker = L.marker([marker.get('latitude'), marker.get('longitude')], {
                icon: L.divIcon(icon_options)
            });
            mapbox_marker.id = marker.id;
            this.marker_layer.addLayer(mapbox_marker);
            var popup = L.popup({ className: 'ca-leaflet-popup '});
            popup.setContent('<div class="soft-half">' + marker.get('address') + '</div>');
            mapbox_marker.bindPopup(popup);
            if (marker.get('radius')) {
                var circle = L.circle([marker.get('latitude'), marker.get('longitude')], parseInt(marker.get('radius'), 10) * 1000);
                this.circle_layer.addLayer(circle);
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
