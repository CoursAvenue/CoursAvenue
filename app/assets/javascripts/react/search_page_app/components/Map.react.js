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
        this.locateUser();
    },

    setLocationOnMap: function setLocationOnMap (location) {
        var marker = L.marker([location.coords.latitude, location.coords.longitude]);
        this.map.addLayer(marker);
        marker.bindPopup('Je suis là !');
        marker.setIcon(L.mapbox.marker.icon({
            'marker-color': '#ff8888',
            'marker-size': 'small'
        }));
    },

    locateUser: function locateUser () {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(this.setLocationOnMap, function() {});
        }
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
            var marker = L.marker([planning.get('_geoloc').lat, planning.get('_geoloc').lng], {
                icon: L.icon({
                    iconUrl: 'assets/icons/svg/danse.svg',
                    // iconRetinaUrl: 'assets/logos/logo.png',
                    iconSize: [38, 95],
                    iconAnchor: [22, 94],
                    popupAnchor: [-3, -76],
                    shadowSize: [68, 95],
                    shadowAnchor: [22, 94]
                })
            });
            // debugger
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
// {
//                     "properties": {
//                         "title": "Big astronaut",
//                         "icon": {
//                           // 'icon-url': 'assets/images/icons/svg/danse.svg'
//                             'iconUrl': 'https://www.mapbox.com/mapbox.js/assets/images/astronaut1.png',
//                             "iconSize": [100, 100],
//                             "iconAnchor": [50, 50],
//                             "popupAnchor": [0, -55],
//                             "className": "dot"

//                         }
//                     }
