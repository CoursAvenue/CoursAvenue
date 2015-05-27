var FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    ServerActionCreators = require("../actions/ServerActionCreators");

var MapComponent = React.createClass({

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        // Create a map in the div #map
        this.marker_layer = L.layerGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets')
                          .setView(this.props.center, 9)
                          .addLayer(this.marker_layer);
        this.map.on('moveend', this.handleMoveend);
        this.props.planning_store.on('all', function() {
            this.updateMarkerLayer();
        }.bind(this));
    },

    handleMoveend: function handleMoveend (leaflet_data) {
        ServerActionCreators.fetchData({
            insideBoundingBox: [
                [this.map.getBounds()._southWest.lat, this.map.getBounds()._southWest.lng],
                [this.map.getBounds()._northEast.lat, this.map.getBounds()._northEast.lng]
            ]
        });
    },

    updateMarkerLayer: function updateMarkerLayer () {
        if (this.props.planning_store.loading) { return; }
        _.each(this.marker_layer.getLayers(), function(marker) {
            this.marker_layer.removeLayer(marker);
        }, this);

        this.props.planning_store.map(function(planning) {
            var marker = L.marker([planning.get('_geoloc').lat, planning.get('_geoloc').lng] );
            this.marker_layer.addLayer(marker);
            marker.bindPopup(planning.get('course_name'));
        }.bind(this));
    },

    render: function render () {
        return (
          <div className="height-35vh one-whole"></div>
        );
    }
});

module.exports = MapComponent;
