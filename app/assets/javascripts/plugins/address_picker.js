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

        init: function() {
            var geocoder;
            this.input_lat      = $(this.$element.data('lat'));
            this.input_lng      = $(this.$element.data('lng'));
            this.input_city     = $(this.$element.data('city'));
            geocoder            = new google.maps.Geocoder();
            this.$element.on('typeahead:selected', function(event, data) {
                this.input_lat.val(data.lat);
                this.input_lng.val(data.lng);
                this.input_city.val(data.city);
                this.$element.typeahead('val', data.address_name);
            }.bind(this));
            template = Handlebars.compile(this.options.template_string);

            this.$element.typeahead({
                    autoselect: true,
                    cache     : false,
                    highlight : true
                }, {
                    templates: {
                        suggestion: template
                    },
                    source: function (query, callback) {
                        query = query + ' France';
                        geocoder.geocode({ address: query }, function (results, status) {
                            callback($.map(results, function (result) {
                                var city, arrAddress = result.address_components;
                                // iterate through address_component array
                                $.each(arrAddress, function (i, address_component) {
                                    if (address_component.types[0] == "locality") {// locality type
                                        city = address_component.long_name;
                                        return false; // break the loop
                                    }
                                });
                                return {
                                    city:         city,
                                    lat:          result.geometry.location.lat(),
                                    lng:          result.geometry.location.lng(),
                                    address_name: result.formatted_address
                                };
                            }));
                        });
                    }
                }
            );
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
