var CardStore              = require("../stores/CardStore"),
    LocationStore          = require("../stores/LocationStore"),
    MetroLineStore         = require("../stores/MetroLineStore"),
    MetroStopStore         = require("../stores/MetroStopStore"),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    LocationActionCreators = require("../actions/LocationActionCreators"),
    Card                   = require("./Card.react"),
    CardActionCreators     = require("../actions/CardActionCreators"),
    FilterActionCreators   = require("../actions/FilterActionCreators");

var MapComponent = React.createClass({

    getInitialState: function getInitialState() {
        return {
            card_store      : CardStore,
            location_store  : LocationStore,
            metro_line_store: MetroLineStore,
            metro_stop_store: MetroStopStore
        };
    },

    componentDidMount: function componentDidMount () {
        this.createMap();
        this.setEventsListeners();
        this.searchCardsWithNewBounds();
    },

    createMap: function createMap () {
        this.small_marker_layer = new L.MarkerClusterGroup({
            disableClusteringAtZoom: 13,
            maxClusterRadius: 30,
            spiderfyOnMaxZoom: true
        });

        this.visible_marker_layer = new L.featureGroup();
        // this.metro_layer          = new L.featureGroup();
        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .setView(this.props.center, 13)
                          .addLayer(this.small_marker_layer)
                          .addLayer(this.visible_marker_layer)
                          // .addLayer(this.metro_layer);
    },

    setEventsListeners: function setEventsListeners () {
        this.map.on('moveend', this.searchCardsWithNewBounds);
        this.map.on('popupclose', function(location) {
            _.each(this.visible_marker_layer.getLayers(), function(marker) {
                $(marker._icon).removeClass('map-box-marker--active');
            });
            _.each(this.small_marker_layer.getLayers(), function(marker) {
                $(marker._icon).removeClass('map-box-marker--active');
            });
            _.defer(CardActionCreators.unhighlightMarkers);
        }.bind(this));
        this.map.on('locationfound', function(location) {
            FilterActionCreators.updateFilters({ user_location: location });
            LocationActionCreators.userLocationFound();
        });
        this.map.on('locationerror', function(data) {
            LocationActionCreators.userLocationNotFound();
        });
        this.state.card_store.on('reset change:visible', this.updateMarkerLayer);
        this.state.card_store.on('change:highlighted', this.showHighlightedMarkerPopup);
        this.state.card_store.on('change:hovered', this.highlightMarker);

        this.state.metro_line_store.on('change', this.showMetroLines.bind(this));
        this.state.metro_stop_store.on('change', function() {
            if (this.state.metro_stop_store.getSelectedStop()) {
                this.map.setView(this.state.metro_stop_store.getSelectedStop().coordinates(), 15);
            }
        }.bind(this));
        this.state.location_store.on('all', function() {
            if (this.state.location_store.changed.hasOwnProperty('fullscreen')) {
                setTimeout(function() { this.map.invalidateSize(); }.bind(this), 10);
            }
            if (this.state.location_store.changed.hasOwnProperty('address')) { this.moveMapToNewAddress(); }
            if (this.state.location_store.changed.hasOwnProperty('user_location')) {
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

    showMetroLines: function showMetroLines (location) {
        // TODO: Load from geojson
        // if (this.state.metro_line_store.getSelectedLines().length == 0) { return; }
        // _.each(this.metro_layer.getLayers(), function(layer) {
        //     this.metro_layer.removeLayer(layer);
        // }, this);
        // var lines = [];
        // _.each(this.state.metro_line_store.getSelectedLines(), function(metro_line) {
        //     if (metro_line.get('ratp_stops_lat_lng')) {
        //         var stops = _.map(metro_line.get('ratp_stops_lat_lng'), function(stop_lat_lng) {
        //             return new L.LatLng(stop_lat_lng[0], stop_lat_lng[1]);
        //         });
        //         var polyline = new L.Polyline(stops, {
        //             color: metro_line.get('color'),
        //             weight: 3,
        //             opacity: 0.8,
        //             smoothFactor: 5
        //         });
        //         this.metro_layer.addLayer(polyline);
        //     }
        // }, this);
    },

    moveMapToNewAddress: function moveMapToNewAddress (location) {
        // We close currently popup if there is one
        if (this.popup && this.popup._isOpen) { this.map.closePopup(this.popup); }
        if (!this.state.location_store.get('address')) { return; }
        this.map.setView([this.state.location_store.get('address').latitude, this.state.location_store.get('address').longitude]);
        if (this.state.location_store.isFilteredByAddress()) { this.setLocationOnMap(); }
    },

    setLocationOnMap: function setLocationOnMap () {
        var location = this.state.location_store.get('user_location') || this.state.location_store.get('address');
        if (!location) { return; }
        if (this.location_marker) { this.map.removeLayer(this.location_marker); }
        this.location_marker = L.marker([location.latitude, location.longitude],
                              { icon: L.divIcon({
                                      className: 'map-box-marker__user',
                                      html     : '<div></div>'
                                  })
                              });
        this.map.addLayer(this.location_marker);
        this.map.setView([location.latitude, location.longitude]);
    },

    searchCardsWithNewBounds: function searchCardsWithNewBounds (leaflet_data) {
        // ----- We add guard to prevent from updating bounds when a popup is opened
        if (this.popup && this.popup._isOpen) { return; }

        if (SearchPageDispatcher.isDispatching()) {
            _.defer(this.searchCardsWithNewBounds, leaflet_data);
            return;
        }
        LocationActionCreators.updateBounds([
            [this.map.getBounds()._southWest.lat, this.map.getBounds()._southWest.lng],
            [this.map.getBounds()._northEast.lat, this.map.getBounds()._northEast.lng]
        ]);
    },

    // Make all marker a little transparent but not highlighted one.
    highlightMarker: function highlightMarker (card) {
        var card_id         = card.get('id');
        var card_is_hovered = card.get('hovered');
        if (card_is_hovered) {
            _.each(this.visible_marker_layer.getLayers(), function(marker) {
                if (marker.card_id != card_id) {
                    marker.setOpacity(0.3);
                    marker.setZIndexOffset(1000);
                } else {
                    marker.setZIndexOffset(10000);
                }
            }, this);
        } else {
            _.each(this.visible_marker_layer.getLayers(), function(marker) {
                marker.setOpacity(1);
            });
        }
    },

    showHighlightedMarkerPopup: function showHighlightedMarkerPopup (card) {
        var card_id = card.get('id');
        highlighted_marker = _.detect(this.visible_marker_layer.getLayers(), function(layer) {
            return layer.card_id == card_id;
        });
        this.openMarkerPopup(highlighted_marker, card)();
    },

    updateMarkerLayer: function updateMarkerLayer () {
        if (this.state.card_store.loading) { return; }

        _.each(this.visible_marker_layer.getLayers(), function(marker) {
            this.visible_marker_layer.removeLayer(marker);
        }, this);
        _.each(this.small_marker_layer.getLayers(), function(marker) {
            this.small_marker_layer.removeLayer(marker);
        }, this);

        this.state.card_store.map(function(card) {
            if (!card.get('_geoloc')) { return; }
            var marker = L.marker([card.get('_geoloc').lat, card.get('_geoloc').lng], {
                icon: this.getIconForCard(card)
            });
            marker.card_id = card.get('id');
            if (card.get('visible')) {
                this.visible_marker_layer.addLayer(marker);
            } else {
                this.small_marker_layer.addLayer(marker);
            }
            marker.on('click', this.openMarkerPopup(marker, card));
        }.bind(this));
    },

    /*
     * Encapsulate marker and card to the function
     */
    openMarkerPopup: function openMarkerPopup (marker, card) {
        return function() {
            var string_popup = React.renderToString(<Card card={card} is_popup={true} />);
            this.popup = L.popup({ className: 'ca-leaflet-popup' })
                .setLatLng(marker.getLatLng())
                .setContent(string_popup)
                .openOn(this.map);
            marker.openPopup(this.popup);
            $(marker._icon).addClass('map-box-marker--active');
        }.bind(this)
    },

    getIconForCard: function getIconForCard (card) {
        if (card.get('visible')) {
            return L.divIcon({
                className: 'map-box-marker map-box-marker__' + card.get('root_subject'),
                html: '<div>' + (this.state.card_store.indexOf(card) + 1) + '</div>'
            });
        } else {
            return L.divIcon({
                className: 'map-box-marker--circle map-box-marker__' + card.get('root_subject'),
            });
        }
    },

    render: function render () {
        return (<div style={{ height: '100%' }}></div>);
    }
});

module.exports = MapComponent;
