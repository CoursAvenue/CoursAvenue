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
            this.input_lat         = $(this.$element.data('lat'));
            this.input_lng         = $(this.$element.data('lng'));
            this.input_city        = $(this.$element.data('city'));
            this.input_radius = $(this.$element.data('radius'));
            geocoder            = new google.maps.Geocoder();
            this.$element.on('typeahead:selected', function(event, data) {
                this.input_lat.val(data.lat);
                this.input_lng.val(data.lng);
                this.input_city.val(data.city);
                this.input_radius.val(data.radius);
                this.$element.typeahead('val', data.address_name);
            }.bind(this));
            template = Handlebars.compile(this.options.template_string);
            this.latest_results = [];
            var engine   = new Bloodhound({
                datumTokenizer: function(d) { return Bloodhound.tokenizers.whitespace(d.num); },
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                remote: {
                    url: 'https://maps.googleapis.com/maps/api/geocode/json?address=%QUERY&components=country:FR&sensor=false&region=fr',
                    filter: function (parsedResponse) {
                        this.latest_results = parsedResponse.results;
                        // query = query + ' France';
                        return _.map(parsedResponse.results, function (result) {
                            var city, arrAddress = result.address_components;
                            // iterate through address_component array to keep only locality type
                            $.each(arrAddress, function (i, address_component) {
                                if (address_component.types[0] == "locality") {// locality type
                                    city = address_component.long_name;
                                    return false; // break the loop
                                }
                            });
                            return {
                                city        : city,
                                lat         : result.geometry.location.lat,
                                lng         : result.geometry.location.lng,
                                address_name: result.formatted_address,
                                radius      : this.getRadiusFromType(result.types[0])
                            };
                        }.bind(this));
                    }.bind(this)
                }
            });
            engine.initialize();
            // Select first of latest results when blurring the input
            this.$element.blur(function() {
                if (this.latest_results.length > 0) {
                    this.input_lat.val(this.latest_results[0].geometry.location.lat);
                    this.input_lng.val(this.latest_results[0].geometry.location.lng);
                    this.input_city.val(this.latest_results[0].formatted_address);
                    this.input_radius.val(this.getRadiusFromType(this.latest_results[0].types[0]));
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
              case 'route'         : return 1;
              case 'street_address': return 1;
              case 'neighborhood'  : return 2;
              case 'locality'      : return 5;
              default              : return 5;
            }
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
    GLOBAL.initialize_callbacks.push(address_picker_initializer);
});
