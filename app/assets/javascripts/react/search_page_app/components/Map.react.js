var FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    PlanningStore        = require("../stores/PlanningStore");
    FilterActionCreators = require("../actions/FilterActionCreators");

var MapComponent = React.createClass({

    getInitialState: function getInitialState() {
        return { planning_store: PlanningStore };
    },

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        // Create a map in the div #map
        this.marker_layer = L.layerGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets')
                          .setView(this.props.center, 9)
                          .addLayer(this.marker_layer);
        this.map.on('moveend', this.handleMoveend);
        this.state.planning_store.on('all', function() {
            this.updateMarkerLayer();
        }.bind(this));
        this.locateUser();
    },

    setLocationOnMap: function setLocationOnMap (location) {
        var marker = L.marker([location.coords.latitude, location.coords.longitude],
                              { icon: L.divIcon({className: 'map-box-marker__user'}) });
        this.map.addLayer(marker);
        marker.bindPopup('Je suis là !');
    },

    locateUser: function locateUser () {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(this.setLocationOnMap, function() {});
        }
    },

    handleMoveend: function handleMoveend (leaflet_data) {
        FilterActionCreators.updateFilters({
            insideBoundingBox: [
                [this.map.getBounds()._southWest.lat, this.map.getBounds()._southWest.lng],
                [this.map.getBounds()._northEast.lat, this.map.getBounds()._northEast.lng]
            ]
        });
    },

    updateMarkerLayer: function updateMarkerLayer () {
        if (this.state.planning_store.loading) { return; }
        _.each(this.marker_layer.getLayers(), function(marker) {
            this.marker_layer.removeLayer(marker);
        }, this);

        this.state.planning_store.map(function(planning) {
            var marker = L.marker([planning.get('_geoloc').lat, planning.get('_geoloc').lng], {
                icon: this.getIconForPlanning(planning)
            });
            this.marker_layer.addLayer(marker);
            marker.bindPopup(planning.get('course_name'));
        }.bind(this));
    },

    getIconForPlanning: function getIconForPlanning (planning) {
        return L.divIcon({
            className: 'map-box-marker map-box-marker__' + planning.get('root_subject_slug')
            // iconUrl: CoursAvenue.MAP_ICONS[planning.get('root_subject_slug')]
            // iconRetinaUrl: 'assets/logos/logo.png',
            // iconSize: [38, 95],
            // iconAnchor: [22, 94],
            // popupAnchor: [-3, -76],
            // shadowSize: [68, 95],
            // shadowAnchor: [22, 94]
        });
    },
    render: function render () {
        return (
          <div className="height-35vh one-whole"></div>
        );
    }
});

module.exports = MapComponent;
