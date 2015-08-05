/*
    Usage:
    <input  data-behavior='address-picker'
            data-list='#address-list'
            data-lng='#address-lng'
            data-lat='#address-lat' />
*/
;(function ( $, window, document, undefined ) {

    // Create the defaults once
    var pluginName = "addressPicker",
        defaults = {
            template_string: '<p data-lat="{{lat}}" data-lng="{{lng}}" data-city="{{city}}">{{address_name}}</p>'
        };

    // The actual plugin constructor
    function Plugin( element, options ) {
        this.element  = element;
        this.$element = $(element);

        // jQuery has an extend method that merges the
        // contents of two or more objects, storing the
        // result in the first object. The first object
        // is generally empty because we don't want to alter
        // the default options for future instances of the plugin
        this.options = $.extend( {}, defaults, options) ;

        this._defaults = defaults;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function init () {
            // Check if the element has already been initialized before doing the stuff
            if (this.$element.hasClass('tt-hint')) { return; }
            var geocoder;
            this.input_lat          = $(this.$element.data('lat'));
            this.input_lng          = $(this.$element.data('lng'));
            this.input_city         = $(this.$element.data('city'));
            this.input_address_name = $(this.$element.data('address-name'));
            this.input_radius       = $(this.$element.data('radius'));
            this.input_zoom         = $(this.$element.data('zoom'));
            geocoder                = new google.maps.Geocoder();
            this.$element.on('typeahead:selected', function(event, data) {
                this.input_lat.val(data.lat);
                this.input_lng.val(data.lng);
                this.input_address_name.val(data.address_name);
                this.input_city.val(data.city);
                this.input_radius.val(data.radius);
                this.input_radius.val(data.radius);
                this.input_zoom.val(data.zoom);
                this.$element.typeahead('val', data.address_name);
            }.bind(this));
            template = Handlebars.compile(this.options.template_string);
            this.latest_results = [];
            var engine   = new Bloodhound({
                datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                remote: {
                    url: 'https://maps.googleapis.com/maps/api/geocode/json?address=%QUERY&components=country:FR&sensor=false&region=fr',
                    filter: function filter (parsedResponse) {
                        this.latest_results = parsedResponse.results;
                        // query = query + ' France';
                        return _.map(parsedResponse.results, function (result) {
                            var city = this.getCityFromAddress(result.address_components);
                            return {
                                city        : city,
                                lat         : result.geometry.location.lat,
                                lng         : result.geometry.location.lng,
                                address_name: result.formatted_address,
                                radius      : this.getRadiusFromType(result.types[0]),
                                zoom        : this.getZoomFromType(result.types[0])
                            };
                        }.bind(this));
                    }.bind(this)
                }
            });
            engine.initialize();
            // Select first of latest results when blurring the input
            this.$element.blur(function() {
                if (this.latest_results.length > 0) {
                    var city = this.getCityFromAddress(this.latest_results[0].address_components);
                    this.input_city.val(city);
                    this.input_lat.val(this.latest_results[0].geometry.location.lat);
                    this.input_lng.val(this.latest_results[0].geometry.location.lng);
                    this.input_address_name.val(this.latest_results[0].formatted_address);
                    this.input_radius.val(this.getRadiusFromType(this.latest_results[0].types[0]));
                    this.input_zoom.val(this.getZoomFromType(this.latest_results[0].types[0]));
                    this.$element.typeahead('val', this.latest_results[0].formatted_address);
                }
            }.bind(this));
            this.$element.typeahead({
                highlight : true,
                minLength: 1,
                autoselect: true
            }, {
                displayKey: 'address_name',
                templates: {
                    suggestion: template
                },
                source: engine.ttAdapter()
            });
        },
        getRadiusFromType: function getRadiusFromType (radius_type) {
            switch(radius_type) {
              case 'street_address': return 1;
              case 'route'         : return 1;
              case 'neighborhood'  : return 2;
              case 'locality'      : return 5;
              default              : return 5;
            }
        },

        getZoomFromType: function getZoomFromType (radius_type) {
            switch(radius_type) {
              case 'street_address'     : return 16;
              case 'route'              : return 16;
              case 'neighborhood'       : return 14;
              case 'locality'           : return 14;
              case 'sublocality_level_1': return 15;
              default                   : return 14;
            }
        },
        getCityFromAddress: function getCityFromAddress (arrAddress) {
            // iterate through address_component array to keep only locality type
            var city;
            $.each(arrAddress, function (i, address_component) {
                // -------- THIS IS FOR PARIS
                if (address_component.types[0] == "sublocality_level_1" &&
                    address_component.long_name.indexOf(' Arrondissement') != -1) {
                    if (address_component.long_name.split('e ')[0].length == 1) {
                        city = 'paris-0' + address_component.long_name.split('e ')[0];
                    } else {
                        city = 'paris-' + address_component.long_name.split('e ')[0];
                    }
                    return false; // break the loop
                } else if (address_component.types[0] == "locality") {// locality type
                    city = address_component.long_name;
                    return false; // break the loop
                }
            });
            return city;
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    }

})( jQuery, window, document );

$(function() {
    var address_picker_initializer = function() {
        $('[data-behavior=address-picker]').addressPicker();
    };
    COURSAVENUE.initialize_callbacks.push(address_picker_initializer);
});
