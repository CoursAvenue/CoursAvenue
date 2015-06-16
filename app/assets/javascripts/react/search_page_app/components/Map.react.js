var FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    CardStore              = require("../stores/CardStore"),
    LocationStore          = require("../stores/LocationStore"),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    FilterActionCreators   = require("../actions/FilterActionCreators");

var MapComponent = React.createClass({

    getInitialState: function getInitialState() {
        return {
            card_store    : CardStore,
            location_store: LocationStore
        };
    },

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        this.createMap();
        this.setEventsListeners()
        this.handleMoveend(); // Trigger map bounds
    },

    createMap: function createMap () {
        this.marker_layer = L.layerGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets')
                          .setView(this.props.center, 13)
                          .addLayer(this.marker_layer);
    },

    setEventsListeners: function setEventsListeners () {
        this.map.on('moveend', this.handleMoveend);
        this.state.card_store.on('all', function() {
            this.updateMarkerLayer();
        }.bind(this));

        this.state.location_store.on('all', function() {
            // Move Map ONLY IF we just changed address
            if (this.state.location_store.changed.address) {       this.moveMapToNewAddress(); }
            if (this.state.location_store.changed.user_location) { this.setLocationOnMap(); }
        }.bind(this));
    },

    moveMapToNewAddress: function moveMapToNewAddress (location) {
        if (!this.state.location_store.get('address')) { return; }
        this.map.setView([this.state.location_store.get('address').latitude, this.state.location_store.get('address').longitude]);
    },

    setLocationOnMap: function setLocationOnMap () {
        var marker = L.marker([this.state.location_store.get('user_location').latitude, this.state.location_store.get('user_location').longitude],
                              { icon: L.divIcon({className: 'map-box-marker__user'}) });
        this.map.addLayer(marker);
        this.map.setView([this.state.location_store.get('user_location').latitude, this.state.location_store.get('user_location').longitude]);
        marker.bindPopup('Je suis là !');
    },

    handleMoveend: function handleMoveend (leaflet_data) {
        if (SearchPageDispatcher.isDispatching()) {
            _.defer(this.handleMoveend, leaflet_data);
            return;
        }
        LocationActionCreators.updateBounds([
            [this.map.getBounds()._southWest.lat, this.map.getBounds()._southWest.lng],
            [this.map.getBounds()._northEast.lat, this.map.getBounds()._northEast.lng]
        ]);
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
