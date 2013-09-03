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
            template_string: '<p data-lat="{{latitude}}" data-lng="{{longitude}}" data-city="{{city}}">{{address}}</p>'
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
            // this.data_list      = $(this.$element.data('list')).hide();
            this.input_lat      = $(this.$element.data('lat'));
            this.input_lng      = $(this.$element.data('lng'));
            this.input_city     = $(this.$element.data('city'));
            this.geocoder       = new google.maps.Geocoder();
            this.$element.on('typeahead:selected', function(event, data) {
                this.input_lat.val(data.latitude);
                this.input_lng.val(data.longitude);
                this.input_city.val(data.city);
                this.$element.val(data.address);
            }.bind(this));
            template = Handlebars.compile(this.options.template_string);
            this.$element.typeahead({
                template: template,
                computed: function (q, done) {
                    q = q + ', France';
                    this.geocoder.geocode({ address: q }, function (results, status) {
                        done($.map(results, function (result) {
                            var city, arrAddress = result.address_components;
                            // iterate through address_component array
                            $.each(arrAddress, function (i, address_component) {
                                if (address_component.types[0] == "locality") {// locality type
                                    city = address_component.long_name;
                                    return false; // break the loop
                                }
                            });
                            return {
                                city: city,
                                latitude: result.geometry.location.lat(),
                                longitude: result.geometry.location.lng(),
                                address: result.formatted_address
                            };
                        }));
                    });
                }.bind(this)
            });
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
        $('[data-behavior=address-picker]').each(function(index, el) {
            $(this).addressPicker();
        });
    };
    GLOBAL.initialize_callbacks.push(address_picker_initializer);
});
