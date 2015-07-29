var CardStore              = require("../stores/CardStore"),
    LocationStore          = require("../stores/LocationStore"),
    MetroStopStore         = require("../stores/MetroStopStore"),
    SearchPageDispatcher   = require('../dispatcher/SearchPageDispatcher'),
    MarkerPopup            = require("./MarkerPopup.react");

var MapComponent = React.createClass({

    getInitialState: function getInitialState() {
        return {
            card_store      : CardStore,
            location_store  : LocationStore
        };
    },

    componentDidMount: function componentDidMount () {
        // Provide your access token
        L.mapbox.accessToken = ENV.MAPBOX_ACCESS_TOKEN;
        this.createMap();
        this.setEventsListeners()
        this.$dom_node = $(this.getDOMNode());
        $(window).scroll(function () {
            if ($(window).scrollTop() > 500) {
                this.$dom_node.addClass('search-page-small-map--visible');
            } else {
                this.$dom_node.removeClass('search-page-small-map--visible');
            }
        }.bind(this));
    },

    createMap: function createMap () {
        this.marker_layer = new L.featureGroup();

        this.map = L.mapbox.map(this.getDOMNode(), this.props.mapId || 'mapbox.streets', { scrollWheelZoom: false })
                          .setView(this.props.center, 13)
                          .addLayer(this.marker_layer);
    },

    setEventsListeners: function setEventsListeners () {
        this.state.card_store.on('reset change:visible', this.updateMarkerLayer);
        this.state.card_store.on('change:hovered', this.highlightMarker);

        this.state.location_store.on('all', function() {
            if (this.state.location_store.changed.hasOwnProperty('address')) { this.moveMapToNewAddress(); }
            if (this.state.location_store.changed.hasOwnProperty('user_location')) {
                if (this.state.location_store.changed.user_location != true) {
                    this.setLocationOnMap();
                }
            }
        }.bind(this));
    },

    moveMapToNewAddress: function moveMapToNewAddress (location) {
        if (!this.state.location_store.get('address')) { return; }
        this.map.setView([this.state.location_store.get('address').latitude, this.state.location_store.get('address').longitude]);
        if (this.state.location_store.isFilteredByAddress()) { this.setLocationOnMap(); }
    },

    setLocationOnMap: function setLocationOnMap () {
        var location = this.state.location_store.get('user_location') || this.state.location_store.get('address');
        if (!location) { return; }
        if (this.location_marker) { this.map.removeLayer(this.location_marker); }
        this.location_marker = L.marker([location.latitude, location.longitude],
                              { icon: L.divIcon({className: 'map-box-marker__user'}) });
        this.map.addLayer(this.location_marker);
        this.map.setView([location.latitude, location.longitude]);
    },


    highlightMarker: function highlightMarker (card) {
        var card_is_hovered = card.get('hovered');
        var card_id = card.get('id');
        _.each(this.marker_layer.getLayers(), function(marker) {
            if (!this.state.card_store.a_card_is_hovered ||
                (card_is_hovered && marker.card.get('id') == card_id)) {
                marker.setIcon(L.divIcon({
                    className: 'relative on-top map-box-marker map-box-marker__' + marker.card.get('root_subject'),
                    html: '<div>' + (this.state.card_store.indexOf(marker.card) + 1) + '</div>'
                }));
            } else {
                marker.setIcon(L.divIcon({
                    className: 'map-box-marker--circle map-box-marker__' + marker.card.get('root_subject'),
                }));
            }
        }, this);
    },

    updateMarkerLayer: function updateMarkerLayer () {
        if (this.state.card_store.loading) { return; }

        _.each(this.marker_layer.getLayers(), function(marker) {
            this.marker_layer.removeLayer(marker);
        }, this);

        this.state.card_store.where({ visible: true }).map(function(card) {
            if (!card.get('_geoloc')) { return; }
            var marker = L.marker([card.get('_geoloc').lat, card.get('_geoloc').lng], {
                icon: L.divIcon({
                    className: 'map-box-marker map-box-marker__' + card.get('root_subject'),
                    html: '<div>' + (this.state.card_store.indexOf(card) + 1) + '</div>'
                })
            });
            marker.card = card;
            this.marker_layer.addLayer(marker);
        }.bind(this));
        if (!_.isEmpty(this.marker_layer.getBounds())) {
            this.map.fitBounds(this.marker_layer.getBounds().pad(0.3));
        }
    },

    render: function render () {
        return (<div className="search-page-small-map on-top fixed south">
                </div>);
    }
});

module.exports = MapComponent;
