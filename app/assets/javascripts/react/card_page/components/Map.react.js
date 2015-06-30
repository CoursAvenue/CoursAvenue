var MetroMarkerPopup = require('./MetroMarkerPopup.react');
var MapComponent = React.createClass({

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        this.createMap();
        this.addMetros();
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

    addMetros: function addMetros () {
        _.each(this.props.metro_stops, function(metro_stop) {
            var marker = L.marker([metro_stop.latitude, metro_stop.longitude], {
                icon: L.divIcon({ className: 'nowrap', html: '<div class="metro-line metro-line-m-for-map v-middle">M</div><span class="v-middle metro-line-station-name">' + metro_stop.name + '</span>' })
            });
            var string_popup = React.renderToString(<MetroMarkerPopup metro_stop={metro_stop} />);
            marker.bindPopup(string_popup, { className: 'ca-leaflet-popup' });
            this.map.addLayer(marker);
        }.bind(this));
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