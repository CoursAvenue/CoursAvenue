var FluxBoneMixin          = require("../../mixins/FluxBoneMixin"),
    CardStore              = require("../stores/CardStore"),
    LocationStore          = require("../stores/LocationStore"),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    MarkerPopup            = require("./MarkerPopup.react"),
    CardActionCreators     = require("../actions/CardActionCreators"),
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
        this.map.on('popupclose', function(location) {
            _.defer(CardActionCreators.unhighlightMarkers);
        });
        this.map.on('locationfound', function(location) {
            FilterActionCreators.updateFilters({ user_location: location });
        });
        this.map.on('locationerror', function(data) { console.warn("Location couldn't be found") });
        this.state.card_store.on('all', function() {
            this.updateMarkerLayer();
        }.bind(this));

        this.state.location_store.on('all', function() {
            // Move Map ONLY IF we just changed address
            if (this.state.location_store.get('finding_user_position')) {
                COURSAVENUE.helperMethods.flash('Localisation en cours...', 'success')
            }
            if (this.state.location_store.changed.address) {       this.moveMapToNewAddress(); }
            if (this.state.location_store.changed.user_location) {
                if (this.state.location_store.changed.user_location == true) {
                    this.locateUser();
                } else {
                    this.setLocationOnMap();
                }
            }
        }.bind(this));
    },

    locateUser: function locateUser (location) {
        this.map.locate({ setView: true, maxZoom: 15 });
    },

    moveMapToNewAddress: function moveMapToNewAddress (location) {
        if (!this.state.location_store.get('address')) { return; }
        this.map.setView([this.state.location_store.get('address').latitude, this.state.location_store.get('address').longitude]);
        if (this.state.location_store.isFilteredByAddress()) { this.setLocationOnMap(); }
    },

    setLocationOnMap: function setLocationOnMap () {
        var location = this.state.location_store.get('user_location') || this.state.location_store.get('address');
        if (this.location_marker) { this.map.removeLayer(this.location_marker); }
        this.location_marker = L.marker([location.latitude, location.longitude],
                              { icon: L.divIcon({className: 'map-box-marker__user'}) });
        this.map.addLayer(this.location_marker);
        this.map.setView([location.latitude, location.longitude]);
        this.location_marker.bindPopup('Je suis là !');
    },

    handleMoveend: function handleMoveend (leaflet_data) {
        // ----- We add guard to prevent from updating bounds when a popup is opened
        var popup_is_opened = _.some(this.marker_layer._layers, function(marker_layer) {
            return marker_layer._popup._isOpen;
        });
        if (popup_is_opened) { return; }

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
            if (!card.get('_geoloc')) { return; }
            var marker = L.marker([card.get('_geoloc').lat, card.get('_geoloc').lng], {
                icon: this.getIconForCard(card)
            });
            this.marker_layer.addLayer(marker);
            var string_popup = React.renderToString(<MarkerPopup card={card} />);
            marker.bindPopup(string_popup, { className: 'ca-leaflet-popup' });
            if (card.get('highlighted')) {
                marker.openPopup()
            }
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
