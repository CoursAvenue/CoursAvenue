var FluxBoneMixin        = require("../../mixins/FluxBoneMixin"),
    CardStore            = require("../stores/CardStore"),
    CityStore            = require("../stores/CityStore"),
    FilterActionCreators = require("../actions/FilterActionCreators");

var MapComponent = React.createClass({

    getInitialState: function getInitialState() {
        return {
            card_store: CardStore,
            city_store: CityStore
        };
    },

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        // Create a map in the div #map
        this.marker_layer = L.layerGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets')
                          .setView(this.props.center, 13)
                          .addLayer(this.marker_layer);
        this.map.on('moveend', this.handleMoveend);
        this.state.card_store.on('all', function() {
            this.updateMarkerLayer();
        }.bind(this));
        this.locateUser();
        this.handleMoveend(); // Trigger map bounds
    },

    setLocationOnMap: function setLocationOnMap (location) {
        var marker = L.marker([location.coords.latitude, location.coords.longitude],
                              { icon: L.divIcon({className: 'map-box-marker__user'}) });
        this.map.addLayer(marker);
        FilterActionCreators.updateFilters({ user_position: location.coords });
        this.map.setView([location.coords.latitude, location.coords.longitude]);
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
        if (this.state.card_store.loading) { return; }
        _.each(this.marker_layer.getLayers(), function(marker) {
            this.marker_layer.removeLayer(marker);
        }, this);

        this.state.card_store.map(function(card) {
            var marker = L.marker([card.get('_geoloc').lat, card.get('_geoloc').lng], {
                icon: this.getIconForCard(card)
            });
            this.marker_layer.addLayer(marker);
            marker.bindPopup(card.get('name'));
        }.bind(this));
    },

    getIconForCard: function getIconForCard (card) {
        return L.divIcon({
            className: 'map-box-marker map-box-marker__' + card.get('root_subject')
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
        var map_style = {
            minHeight: '230px'
        };
        return (
          <div className="height-35vh" style={map_style}></div>
        );
    }
});

module.exports = MapComponent;
